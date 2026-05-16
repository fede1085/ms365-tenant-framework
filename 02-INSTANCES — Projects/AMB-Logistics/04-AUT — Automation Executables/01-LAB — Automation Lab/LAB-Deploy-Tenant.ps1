<#
Tenant-local controlled runtime
Production-ready guarded execution
Protected-object enforced
No license assignment
No destructive default behavior
#>

Param(
    [String]$MTXDir,
    [Switch]$DryRun,
    [Parameter(Mandatory=$true)][String]$TenantId,
    [Parameter(Mandatory=$true)][String]$TenantDomain,
    [String]$ProtectedGlobalAdminObjectId,
    [Switch]$ConfirmationPhraseAccepted
)

if (-not $PSBoundParameters.ContainsKey("DryRun")) {
    $DryRun = $true
}

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProtectedObjectsPath = Join-Path $ScriptRoot "LAB-Protected-Objects.ps1"
if (-not (Test-Path -LiteralPath $ProtectedObjectsPath)) {
    throw "Protected object policy file missing. Execution blocked."
}
. $ProtectedObjectsPath
if (-not [string]::IsNullOrWhiteSpace($ProtectedGlobalAdminObjectId)) {
    [void](Add-LabProtectedObjectId -ObjectId $ProtectedGlobalAdminObjectId)
}
[void](Confirm-LabProtectedBaseline)

$ProtectedSummary = Get-LabProtectedObjectSummary
Write-Host ">>> Starting AMB-Logistics tenant-local controlled runtime..." -ForegroundColor Green
Write-Host ">>> Protected object policy loaded: $($ProtectedSummary.Boundary)" -ForegroundColor Yellow
if (-not $ProtectedSummary.ObjectIdResolved) {
    Write-Warning "Protected ObjectId values unresolved; protection continues by UPN, alias, display name, and role."
}

if (-not (Test-Path -LiteralPath $MTXDir)) {
    throw "MTX directory not found: $MTXDir"
}

function Test-LabMatrixSchema {
    Param(
        [String]$MatrixName,
        [String[]]$RequiredColumns
    )

    $MatrixPath = Join-Path $MTXDir $MatrixName
    if (-not (Test-Path -LiteralPath $MatrixPath)) {
        throw "Required MTX file not found: $MatrixPath"
    }

    $Rows = @(Import-Csv $MatrixPath)
    $Columns = @($Rows | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name -Unique)
    $MissingColumns = @($RequiredColumns | Where-Object { $_ -notin $Columns })
    if ($MissingColumns.Count -gt 0) {
        throw "$MatrixName missing required column(s): $($MissingColumns -join ', ')"
    }

    Write-Host "[VALIDATED] $MatrixName schema; row count $($Rows.Count)." -ForegroundColor Cyan
}

function Test-LabRuntimeDependencies {
    $RequiredCommands = @(
        "Connect-MgGraph",
        "Get-MgContext",
        "Get-MgUser",
        "New-MgUser",
        "Update-MgUser",
        "Get-MgGroup",
        "New-MgGroup",
        "Update-MgGroup",
        "New-MgGroupMemberByRef",
        "New-MgGroupOwnerByRef",
        "Connect-ExchangeOnline",
        "Get-Mailbox",
        "New-Mailbox",
        "Set-Mailbox",
        "Set-User",
        "Get-MailboxPermission",
        "Add-MailboxPermission",
        "Get-RecipientPermission",
        "Add-RecipientPermission"
    )

    foreach ($CommandName in $RequiredCommands) {
        if (-not (Get-Command -Name $CommandName -ErrorAction SilentlyContinue)) {
            throw "Required runtime dependency command not available: $CommandName"
        }
    }

    Write-Host "[VALIDATED] Microsoft Graph and Exchange Online command dependencies are available." -ForegroundColor Cyan
}

if (-not $DryRun -and -not $ConfirmationPhraseAccepted) {
    throw "Execution blocked. Non-DryRun requires entry-point confirmation phrase."
}

Write-Host "[TARGET TENANT]" -ForegroundColor Yellow
Write-Host "TenantId:     $TenantId"
Write-Host "TenantDomain: $TenantDomain"

Test-LabMatrixSchema -MatrixName "MTX-USERS.csv" -RequiredColumns @("UserID", "DisplayName", "FirstName", "LastName", "UserPrincipalName", "MailNickname", "Department", "JobTitle", "UsageLocation", "LicenseSKU", "PasswordProfile", "AccountEnabled")
Test-LabMatrixSchema -MatrixName "MTX-GROUPS.csv" -RequiredColumns @("GroupID", "DisplayName", "GroupType", "MailNickname", "PrimarySMTP", "Department", "Description", "OwnerUPN", "MailEnabled", "SecurityEnabled")
Test-LabMatrixSchema -MatrixName "MTX-MAILBOXES.csv" -RequiredColumns @("MailboxID", "DisplayName", "Alias", "TargetAddress", "Department", "Purpose", "OwnerUPN", "Enabled")
Test-LabMatrixSchema -MatrixName "MTX-PERMISSIONS.csv" -RequiredColumns @("PermissionID", "ObjectType", "ObjectName", "TargetAddress", "UserUPN", "AccessType", "RoleScope", "Enabled")
Test-LabMatrixSchema -MatrixName "MTX-LICENSES.csv" -RequiredColumns @("LicenseID", "UserPrincipalName", "LicenseSKU", "UsageLocation", "AssignmentState", "Notes")

if (-not $DryRun) {
    Test-LabRuntimeDependencies
}

$ValidationParams = @{
    MTXDir                       = $MTXDir
    DryRun                       = $true
    TenantId                     = $TenantId
    TenantDomain                 = $TenantDomain
    ProtectedGlobalAdminObjectId = $ProtectedGlobalAdminObjectId
}
& (Join-Path $ScriptRoot "LAB-Validation-Report.ps1") @ValidationParams

if (-not $DryRun) {
    [void](Confirm-LabProtectedBaseline)

    Connect-MgGraph -TenantId $TenantId
    Connect-ExchangeOnline -Organization $TenantDomain -ShowBanner:$false

    $MgContext = Get-MgContext
    if ($null -eq $MgContext -or $MgContext.TenantId -ne $TenantId) {
        throw "Connected Graph tenant does not match target TenantId. Execution blocked."
    }

    if (-not [string]::IsNullOrWhiteSpace($MgContext.Account)) {
        Set-LabCurrentConnectedUser -UserPrincipalName $MgContext.Account
        $ConnectedUserProtection = Assert-LabNotProtectedObject -InputObject ([PSCustomObject]@{ UserPrincipalName = $MgContext.Account }) -ObjectType "ConnectedUser" -ObjectName $MgContext.Account -AttemptedAction "Protect current connected user from mutation"
        if (-not $ConnectedUserProtection.IsProtected) {
            Write-Host "[VALIDATED] Current connected user added to runtime mutation protection: $($MgContext.Account)" -ForegroundColor Yellow
        }
    }

    foreach ($ProtectedUPN in $ProtectedSummary.ProtectedUPNs) {
        $ResolvedProtectedObject = $null
        try {
            $ResolvedProtectedObject = Get-MgUser -UserId $ProtectedUPN -ErrorAction Stop
        } catch {
            $ResolvedProtectedObject = $null
        }

        if ($null -ne $ResolvedProtectedObject -and -not [string]::IsNullOrWhiteSpace($ResolvedProtectedObject.Id)) {
            [void](Add-LabProtectedObjectId -ObjectId $ResolvedProtectedObject.Id)
            Write-Host "[VALIDATED] Protected ObjectId resolved and added: $ProtectedUPN" -ForegroundColor Yellow
        } else {
            Write-Warning "Protected ObjectId unresolved for $ProtectedUPN; protection continues by UPN, alias, display name, and role."
        }
    }

    [void](Confirm-LabProtectedBaseline)
} else {
    Write-Host "[DRY-RUN] Would connect to Microsoft Graph tenant $TenantId and Exchange organization $TenantDomain." -ForegroundColor Gray
}

Write-Host "[LICENSES] License assignment is explicitly skipped by this runtime." -ForegroundColor Yellow

$Modules = @(
    "LAB-Create-Users.ps1",
    "LAB-Create-Groups.ps1",
    "LAB-Create-Mailboxes.ps1",
    "LAB-Apply-Permissions.ps1",
    "LAB-Validation-Report.ps1"
)

foreach ($Module in $Modules) {
    Write-Host "`n>>> Running Module: $Module" -ForegroundColor Blue
    $ModuleParams = @{
        MTXDir                       = $MTXDir
        DryRun                       = $DryRun
        TenantId                     = $TenantId
        TenantDomain                 = $TenantDomain
        ProtectedGlobalAdminObjectId = $ProtectedGlobalAdminObjectId
    }
    if ($Module -eq "LAB-Validation-Report.ps1" -and -not $DryRun) {
        $ModuleParams["LiveValidation"] = $true
    }
    & (Join-Path $ScriptRoot $Module) @ModuleParams
}

Write-Host "`n>>> Controlled runtime operation complete. Delete/reset disabled by default." -ForegroundColor Green
