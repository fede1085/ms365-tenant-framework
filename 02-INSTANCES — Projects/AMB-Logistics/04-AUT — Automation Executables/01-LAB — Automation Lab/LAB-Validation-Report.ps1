<#
LAB / EXPERIMENTAL / NON-CANONICAL
Disposable execution layer
Safe to delete
Not authoritative framework governance
#>

Param(
    [String]$MTXDir,
    [Switch]$DryRun,
    [String]$TenantId,
    [String]$TenantDomain
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
if (-not (Test-LabProtectedIdentity -UPN "homelab@federicomosqueira0910.onmicrosoft.com" -DisplayName "GLOBAL-Admin" -Role "Global Administrator")) {
    throw "GLOBAL-Admin protected identity is not registered. Execution blocked."
}
$ProtectedSummary = Get-LabProtectedObjectSummary
$ScriptDir = $ScriptRoot
$ReportsDir = Join-Path $ScriptDir "reports"
$LogsDir = Join-Path $ScriptDir "logs"
$TranscriptsDir = Join-Path $ScriptDir "transcripts"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$ReportPath = Join-Path $ReportsDir "LAB-Validation-Report-$Timestamp.md"
$SummaryPath = Join-Path $ReportsDir "LAB-Validation-Summary-$Timestamp.json"
$LogPath = Join-Path $LogsDir "LAB-Validation-Summary-$Timestamp.log"
$TranscriptPath = Join-Path $TranscriptsDir "LAB-Validation-Transcript-$Timestamp.log"

foreach ($Directory in @($ReportsDir, $LogsDir, $TranscriptsDir)) {
    if (-not (Test-Path -LiteralPath $Directory)) {
        New-Item -ItemType Directory -Path $Directory | Out-Null
    }
}

$AllowedStates = @(
    "PENDING",
    "VALIDATING",
    "READY",
    "CREATING",
    "UPDATING",
    "SKIPPED",
    "SKIPPED_PROTECTED",
    "WAITING_PROPAGATION",
    "VALIDATING_RESULT",
    "COMPLETED",
    "WARNING",
    "FAILED",
    "BLOCKED",
    "ROLLBACK_REQUIRED"
)

$AllowedObjectTypes = @("SharedMailbox", "M365Group", "Team", "SharePointSite", "SecurityGroup")
$AllowedAccessTypes = @("FullAccess", "SendAs", "SendOnBehalf", "Member", "Owner", "Read", "Edit", "FullControl")
$ExchangeAccessTypes = @("FullAccess", "SendAs", "SendOnBehalf")
$MembershipAccessTypes = @("Member", "Owner")
$SharePointAccessTypes = @("Read", "Edit", "FullControl")
$BooleanValues = @("True", "False")

$ValidationRecords = New-Object System.Collections.Generic.List[Object]
$FailedCount = 0
$BlockedCount = 0
$WarningCount = 0
$WaitingPropagationCount = 0
$ValidatedCount = 0
$CompletedCount = 0

function Add-ValidationRecord {
    Param(
        [Parameter(Mandatory=$true)][String]$Status,
        [Parameter(Mandatory=$true)][String]$Scope,
        [Parameter(Mandatory=$true)][String]$Message,
        [String]$Reference = ""
    )

    if ($Status -notin $AllowedStates) {
        $Status = "FAILED"
        $Message = "Invalid validation state emitted by LAB validator."
    }

    $script:ValidationRecords.Add([PSCustomObject]@{
        Status    = $Status
        Scope     = $Scope
        Message   = $Message
        Reference = $Reference
    })

    switch ($Status) {
        "FAILED" { $script:FailedCount++ }
        "BLOCKED" { $script:BlockedCount++ }
        "WARNING" { $script:WarningCount++ }
        "WAITING_PROPAGATION" { $script:WaitingPropagationCount++ }
        "VALIDATING_RESULT" { $script:ValidatedCount++ }
        "COMPLETED" { $script:CompletedCount++ }
    }

    $Color = "White"
    if ($Status -in @("FAILED", "BLOCKED", "ROLLBACK_REQUIRED")) { $Color = "Red" }
    elseif ($Status -in @("WARNING", "WAITING_PROPAGATION", "SKIPPED_PROTECTED")) { $Color = "Yellow" }
    elseif ($Status -in @("VALIDATING_RESULT", "READY")) { $Color = "Cyan" }
    elseif ($Status -eq "COMPLETED") { $Color = "Green" }
    Write-Host "[$Status] $Scope - $Message" -ForegroundColor $Color
}

function Test-RequiredColumns {
    Param(
        [String]$MatrixName,
        [Object[]]$Rows,
        [String[]]$RequiredColumns
    )

    $Columns = @($Rows | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name -Unique)
    $MissingColumns = @($RequiredColumns | Where-Object { $_ -notin $Columns })
    if ($MissingColumns.Count -gt 0) {
        Add-ValidationRecord -Status "FAILED" -Scope $MatrixName -Message "Missing required column(s): $($MissingColumns -join ', ')." -Reference $MatrixName
        return $false
    }

    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $MatrixName -Message "Required columns present; row count $($Rows.Count)." -Reference $MatrixName
    return $true
}

function Add-DuplicateValueRecords {
    Param(
        [Object[]]$Rows,
        [String]$Column,
        [String]$MatrixName
    )

    $Duplicates = @($Rows |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_.$Column) } |
        Group-Object -Property $Column |
        Where-Object { $_.Count -gt 1 })

    foreach ($Duplicate in $Duplicates) {
        Add-ValidationRecord -Status "FAILED" -Scope $MatrixName -Message "Duplicate $Column value '$($Duplicate.Name)' appears $($Duplicate.Count) times." -Reference $Column
    }
}

function Add-ToMap {
    Param(
        [Hashtable]$Map,
        [String]$Key,
        [Object]$Value
    )

    if (-not [string]::IsNullOrWhiteSpace($Key) -and -not $Map.ContainsKey($Key)) {
        $Map[$Key] = $Value
    }
}

function Resolve-GroupForPermission {
    Param([Object]$Permission)

    $Candidates = @($Groups | Where-Object {
        $_.DisplayName -eq $Permission.ObjectName -or
        $_.PrimarySMTP -eq $Permission.TargetAddress -or
        $_.MailNickname -eq $Permission.TargetAddress
    })
    return @($Candidates | Select-Object -First 1)
}

function Resolve-MailboxForPermission {
    Param([Object]$Permission)

    $Candidates = @($Mailboxes | Where-Object {
        $_.DisplayName -eq $Permission.ObjectName -or
        $_.TargetAddress -eq $Permission.TargetAddress -or
        $_.Alias -eq $Permission.TargetAddress
    })
    return @($Candidates | Select-Object -First 1)
}

function Get-ExpectedPermissionTarget {
    Param([Object]$Permission)

    switch ($Permission.ObjectType) {
        "SharedMailbox" {
            $Mailbox = Resolve-MailboxForPermission $Permission
            if ($Mailbox.Count -eq 0) { return $null }
            return $Mailbox[0].TargetAddress
        }
        { $_ -in @("M365Group", "Team") } {
            $Group = Resolve-GroupForPermission $Permission
            if ($Group.Count -eq 0) { return $null }
            return $Group[0].PrimarySMTP
        }
        "SecurityGroup" {
            $Group = Resolve-GroupForPermission $Permission
            if ($Group.Count -eq 0) { return $null }
            # Security groups in this MTX are not mail-enabled. TargetAddress is
            # intentionally MailNickname, with DisplayName as the last fallback.
            if (-not [string]::IsNullOrWhiteSpace($Group[0].MailNickname)) {
                return $Group[0].MailNickname
            }
            return $Group[0].DisplayName
        }
        default {
            return $Permission.TargetAddress
        }
    }
}

$TranscriptStarted = $false
try {
    Start-Transcript -Path $TranscriptPath -Force | Out-Null
    $TranscriptStarted = $true

    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host "LAB VALIDATION REPORT - AMB LOGISTICS" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan

    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "LAB-Protected-Objects.ps1 exists and was imported fail-closed." -Reference $ProtectedObjectsPath
    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "GLOBAL-Admin protected UPN is present: $($ProtectedSummary.ProtectedUPNs -join ', ')." -Reference "LAB-Protected-Objects.ps1"
    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "GLOBAL-Admin protected aliases are present: $($ProtectedSummary.ProtectedAliases -join ', ')." -Reference "LAB-Protected-Objects.ps1"
    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "GLOBAL-Admin protected display name is present: $($ProtectedSummary.ProtectedDisplayNames -join ', ')." -Reference "LAB-Protected-Objects.ps1"
    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "SKIPPED_PROTECTED is supported by LAB validation states." -Reference "AUT-SYS-001"

    if ($ProtectedSummary.ProtectedObjectIds -contains "<UNKNOWN_OBJECT_ID_GLOBAL_ADMIN>") {
        Add-ValidationRecord -Status "WARNING" -Scope "ProtectedObjectPolicy" -Message "GLOBAL-Admin ObjectId is still unknown; placeholder is present." -Reference "LAB-Protected-Objects.ps1"
    }

    foreach ($ScriptName in @("LAB-Run-Project.ps1", "LAB-Deploy-Tenant.ps1", "LAB-Create-Users.ps1", "LAB-Create-Groups.ps1", "LAB-Create-Mailboxes.ps1", "LAB-Apply-Permissions.ps1", "LAB-Validation-Report.ps1")) {
        $ScriptPath = Join-Path $ScriptDir $ScriptName
        $ScriptText = Get-Content -LiteralPath $ScriptPath -Raw
        if ($ScriptText -match "LAB-Protected-Objects\.ps1" -and $ScriptText -match "Execution blocked") {
            Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $ScriptName -Message "Imports protected-object policy and fails closed if missing." -Reference $ScriptName
        } else {
            Add-ValidationRecord -Status "BLOCKED" -Scope $ScriptName -Message "Protected-object policy import or fail-closed guard is missing." -Reference $ScriptName
        }

        if ($ScriptName -in @("LAB-Create-Users.ps1", "LAB-Create-Groups.ps1", "LAB-Create-Mailboxes.ps1", "LAB-Apply-Permissions.ps1")) {
            if ($ScriptText -match "Assert-LabNotProtectedObject") {
                Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $ScriptName -Message "Protected-object checks are present before write actions." -Reference $ScriptName
            } else {
                Add-ValidationRecord -Status "BLOCKED" -Scope $ScriptName -Message "Protected-object checks before write actions are missing." -Reference $ScriptName
            }
        }
    }

    $MatrixSchemas = @{
        "MTX-USERS.csv"       = @("UserID", "DisplayName", "FirstName", "LastName", "UserPrincipalName", "MailNickname", "Department", "JobTitle", "UsageLocation", "LicenseSKU", "PasswordProfile", "AccountEnabled")
        "MTX-GROUPS.csv"      = @("GroupID", "DisplayName", "GroupType", "MailNickname", "PrimarySMTP", "Department", "Description", "OwnerUPN", "MailEnabled", "SecurityEnabled")
        "MTX-MAILBOXES.csv"   = @("MailboxID", "DisplayName", "Alias", "TargetAddress", "Department", "Purpose", "OwnerUPN", "Enabled")
        "MTX-PERMISSIONS.csv" = @("PermissionID", "ObjectType", "ObjectName", "TargetAddress", "UserUPN", "AccessType", "RoleScope", "Enabled")
        "MTX-LICENSES.csv"    = @("LicenseID", "UserID", "SKU", "Status")
    }

    $MatrixData = @{}
    foreach ($MatrixName in $MatrixSchemas.Keys) {
        $MatrixPath = Join-Path $MTXDir $MatrixName
        Add-ValidationRecord -Status "VALIDATING" -Scope $MatrixName -Message "Checking required file and schema." -Reference $MatrixPath

        if (-not (Test-Path -LiteralPath $MatrixPath)) {
            Add-ValidationRecord -Status "FAILED" -Scope $MatrixName -Message "Matrix file not found." -Reference $MatrixPath
            continue
        }

        $Rows = @(Import-Csv $MatrixPath)
        $MatrixData[$MatrixName] = $Rows
        [void](Test-RequiredColumns -MatrixName $MatrixName -Rows $Rows -RequiredColumns $MatrixSchemas[$MatrixName])
    }

    $RequiredMatricesLoaded = $true
    foreach ($MatrixName in $MatrixSchemas.Keys) {
        if (-not $MatrixData.ContainsKey($MatrixName)) {
            $RequiredMatricesLoaded = $false
        }
    }

    if ($RequiredMatricesLoaded) {
        $Users = @($MatrixData["MTX-USERS.csv"])
        $Groups = @($MatrixData["MTX-GROUPS.csv"])
        $Mailboxes = @($MatrixData["MTX-MAILBOXES.csv"])
        $Permissions = @($MatrixData["MTX-PERMISSIONS.csv"])
        $Licenses = @($MatrixData["MTX-LICENSES.csv"])

        foreach ($Check in @(
            @{ Rows = $Users; Column = "UserID"; Matrix = "MTX-USERS.csv" },
            @{ Rows = $Users; Column = "UserPrincipalName"; Matrix = "MTX-USERS.csv" },
            @{ Rows = $Users; Column = "MailNickname"; Matrix = "MTX-USERS.csv" },
            @{ Rows = $Groups; Column = "GroupID"; Matrix = "MTX-GROUPS.csv" },
            @{ Rows = $Groups; Column = "DisplayName"; Matrix = "MTX-GROUPS.csv" },
            @{ Rows = $Groups; Column = "MailNickname"; Matrix = "MTX-GROUPS.csv" },
            @{ Rows = $Mailboxes; Column = "MailboxID"; Matrix = "MTX-MAILBOXES.csv" },
            @{ Rows = $Mailboxes; Column = "Alias"; Matrix = "MTX-MAILBOXES.csv" },
            @{ Rows = $Mailboxes; Column = "TargetAddress"; Matrix = "MTX-MAILBOXES.csv" },
            @{ Rows = $Permissions; Column = "PermissionID"; Matrix = "MTX-PERMISSIONS.csv" },
            @{ Rows = $Licenses; Column = "LicenseID"; Matrix = "MTX-LICENSES.csv" }
        )) {
            Add-DuplicateValueRecords -Rows $Check.Rows -Column $Check.Column -MatrixName $Check.Matrix
        }

        $UserByID = @{}
        $UserByUPN = @{}
        $GroupByDisplayName = @{}
        $GroupByPrimarySMTP = @{}
        $GroupByMailNickname = @{}
        $MailboxByDisplayName = @{}
        $MailboxByAddress = @{}
        $MailboxByAlias = @{}

        foreach ($User in $Users) {
            Add-ToMap -Map $UserByID -Key $User.UserID -Value $User
            Add-ToMap -Map $UserByUPN -Key $User.UserPrincipalName -Value $User

            if ($User.AccountEnabled -notin $BooleanValues) {
                Add-ValidationRecord -Status "WARNING" -Scope $User.UserID -Message "AccountEnabled must be True or False: $($User.AccountEnabled)." -Reference "MTX-USERS.csv"
            }
        }

        foreach ($Group in $Groups) {
            Add-ToMap -Map $GroupByDisplayName -Key $Group.DisplayName -Value $Group
            Add-ToMap -Map $GroupByPrimarySMTP -Key $Group.PrimarySMTP -Value $Group
            Add-ToMap -Map $GroupByMailNickname -Key $Group.MailNickname -Value $Group

            if (-not $UserByUPN.ContainsKey($Group.OwnerUPN)) {
                Add-ValidationRecord -Status "WARNING" -Scope $Group.GroupID -Message "Group owner UPN does not resolve to MTX-USERS UserPrincipalName: $($Group.OwnerUPN)." -Reference "MTX-GROUPS.csv"
            }
            if ($Group.GroupType -notin @("Microsoft365", "M365Group", "Security")) {
                Add-ValidationRecord -Status "WARNING" -Scope $Group.GroupID -Message "GroupType is outside LAB-supported values: $($Group.GroupType)." -Reference "MTX-GROUPS.csv"
            }
            if ($Group.MailEnabled -notin $BooleanValues) {
                Add-ValidationRecord -Status "WARNING" -Scope $Group.GroupID -Message "MailEnabled must be True or False: $($Group.MailEnabled)." -Reference "MTX-GROUPS.csv"
            }
            if ($Group.SecurityEnabled -notin $BooleanValues) {
                Add-ValidationRecord -Status "WARNING" -Scope $Group.GroupID -Message "SecurityEnabled must be True or False: $($Group.SecurityEnabled)." -Reference "MTX-GROUPS.csv"
            }
            if ($Group.MailEnabled -eq "True" -and [string]::IsNullOrWhiteSpace($Group.PrimarySMTP)) {
                Add-ValidationRecord -Status "WARNING" -Scope $Group.GroupID -Message "Mail-enabled group has no PrimarySMTP." -Reference "MTX-GROUPS.csv"
            }
            if ($Group.MailEnabled -eq "False" -and -not [string]::IsNullOrWhiteSpace($Group.PrimarySMTP)) {
                Add-ValidationRecord -Status "WARNING" -Scope $Group.GroupID -Message "Non-mail-enabled group has PrimarySMTP populated." -Reference "MTX-GROUPS.csv"
            }
        }

        foreach ($Mailbox in $Mailboxes) {
            Add-ToMap -Map $MailboxByDisplayName -Key $Mailbox.DisplayName -Value $Mailbox
            Add-ToMap -Map $MailboxByAddress -Key $Mailbox.TargetAddress -Value $Mailbox
            Add-ToMap -Map $MailboxByAlias -Key $Mailbox.Alias -Value $Mailbox

            if (-not $UserByUPN.ContainsKey($Mailbox.OwnerUPN)) {
                Add-ValidationRecord -Status "WARNING" -Scope $Mailbox.MailboxID -Message "Mailbox owner UPN does not resolve to MTX-USERS UserPrincipalName: $($Mailbox.OwnerUPN)." -Reference "MTX-MAILBOXES.csv"
            }
            if ($Mailbox.Enabled -notin $BooleanValues) {
                Add-ValidationRecord -Status "WARNING" -Scope $Mailbox.MailboxID -Message "Enabled must be True or False: $($Mailbox.Enabled)." -Reference "MTX-MAILBOXES.csv"
            }
            if ([string]::IsNullOrWhiteSpace($Mailbox.TargetAddress)) {
                Add-ValidationRecord -Status "WARNING" -Scope $Mailbox.MailboxID -Message "TargetAddress is empty." -Reference "MTX-MAILBOXES.csv"
            }
        }

        $PermissionCompositeKeys = @{}
        foreach ($Permission in $Permissions) {
            if ($Permission.Enabled -notin $BooleanValues) {
                Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "Enabled must be True or False: $($Permission.Enabled)." -Reference "MTX-PERMISSIONS.csv"
            }
            if ($Permission.ObjectType -notin $AllowedObjectTypes) {
                Add-ValidationRecord -Status "FAILED" -Scope $Permission.PermissionID -Message "Invalid ObjectType: $($Permission.ObjectType)." -Reference "MTX-PERMISSIONS.csv"
                continue
            }
            if ($Permission.AccessType -notin $AllowedAccessTypes) {
                Add-ValidationRecord -Status "FAILED" -Scope $Permission.PermissionID -Message "Invalid AccessType: $($Permission.AccessType)." -Reference "MTX-PERMISSIONS.csv"
                continue
            }
            if (-not $UserByUPN.ContainsKey($Permission.UserUPN)) {
                Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "Permission UserUPN does not resolve to MTX-USERS UserPrincipalName: $($Permission.UserUPN)." -Reference "MTX-PERMISSIONS.csv"
            }

            if ($Permission.ObjectType -eq "SharedMailbox" -and $Permission.AccessType -notin $ExchangeAccessTypes) {
                Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "SharedMailbox AccessType should be one of: $($ExchangeAccessTypes -join ', ')." -Reference "MTX-PERMISSIONS.csv"
            }
            if ($Permission.ObjectType -in @("M365Group", "Team", "SecurityGroup") -and $Permission.AccessType -notin $MembershipAccessTypes) {
                Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "$($Permission.ObjectType) AccessType should be Member or Owner." -Reference "MTX-PERMISSIONS.csv"
            }
            if ($Permission.ObjectType -eq "SharePointSite" -and $Permission.AccessType -notin $SharePointAccessTypes) {
                Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "SharePointSite AccessType should be one of: $($SharePointAccessTypes -join ', ')." -Reference "MTX-PERMISSIONS.csv"
            }

            $ExpectedTarget = Get-ExpectedPermissionTarget $Permission
            if ([string]::IsNullOrWhiteSpace($ExpectedTarget)) {
                Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "Permission target cannot be resolved from MTX files: $($Permission.ObjectName)." -Reference "MTX-PERMISSIONS.csv"
            } elseif ($Permission.TargetAddress -ne $ExpectedTarget) {
                Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "TargetAddress '$($Permission.TargetAddress)' should be '$ExpectedTarget'." -Reference "MTX-PERMISSIONS.csv"
            } elseif ($Permission.ObjectType -eq "SecurityGroup") {
                Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $Permission.PermissionID -Message "SecurityGroup TargetAddress uses MailNickname exception: $($Permission.TargetAddress)." -Reference "MTX-PERMISSIONS.csv"
            }

            $CompositeKey = "$($Permission.ObjectType)|$($Permission.TargetAddress)|$($Permission.UserUPN)|$($Permission.AccessType)|$($Permission.Enabled)"
            if ($PermissionCompositeKeys.ContainsKey($CompositeKey)) {
                Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "Duplicate permission assignment also appears at $($PermissionCompositeKeys[$CompositeKey])." -Reference "MTX-PERMISSIONS.csv"
            } else {
                $PermissionCompositeKeys[$CompositeKey] = $Permission.PermissionID
            }
        }

        foreach ($License in $Licenses) {
            if (-not $UserByID.ContainsKey($License.UserID)) {
                Add-ValidationRecord -Status "WARNING" -Scope $License.LicenseID -Message "License UserID does not resolve to MTX-USERS UserID: $($License.UserID)." -Reference "MTX-LICENSES.csv"
            } else {
                $User = $UserByID[$License.UserID]
                if (-not [string]::IsNullOrWhiteSpace($User.LicenseSKU) -and $User.LicenseSKU -ne $License.SKU) {
                    Add-ValidationRecord -Status "WARNING" -Scope $License.LicenseID -Message "License SKU '$($License.SKU)' differs from MTX-USERS LicenseSKU '$($User.LicenseSKU)' for $($License.UserID)." -Reference "MTX-LICENSES.csv"
                }
            }
        }

        Add-ValidationRecord -Status "WAITING_PROPAGATION" -Scope "TenantDrift" -Message "Live tenant drift validation intentionally not executed by LAB static validator." -Reference "AUT-OPS-001"
        Add-ValidationRecord -Status "COMPLETED" -Scope "StaticValidation" -Message "MTX schema and relationship validation completed without tenant execution." -Reference "AUT-SYS-001"
    } else {
        Add-ValidationRecord -Status "BLOCKED" -Scope "StaticValidation" -Message "One or more required MTX files are missing; relationship validation skipped." -Reference $MTXDir
    }

    $Counts = [PSCustomObject]@{
        Users       = if ($MatrixData.ContainsKey("MTX-USERS.csv")) { @($MatrixData["MTX-USERS.csv"]).Count } else { 0 }
        Groups      = if ($MatrixData.ContainsKey("MTX-GROUPS.csv")) { @($MatrixData["MTX-GROUPS.csv"]).Count } else { 0 }
        Mailboxes   = if ($MatrixData.ContainsKey("MTX-MAILBOXES.csv")) { @($MatrixData["MTX-MAILBOXES.csv"]).Count } else { 0 }
        Permissions = if ($MatrixData.ContainsKey("MTX-PERMISSIONS.csv")) { @($MatrixData["MTX-PERMISSIONS.csv"]).Count } else { 0 }
        Licenses    = if ($MatrixData.ContainsKey("MTX-LICENSES.csv")) { @($MatrixData["MTX-LICENSES.csv"]).Count } else { 0 }
    }

    $OverallStatus = "COMPLETED"
    if ($FailedCount -gt 0) { $OverallStatus = "FAILED" }
    elseif ($BlockedCount -gt 0) { $OverallStatus = "BLOCKED" }
    elseif ($WarningCount -gt 0) { $OverallStatus = "WARNING" }

    $Summary = [PSCustomObject]@{
        Project            = "AMB Logistics"
        GeneratedAt        = (Get-Date).ToString("o")
        Mode               = if ($DryRun) { "DRY-RUN-STATIC-VALIDATION" } else { "STATIC-VALIDATION" }
        OverallStatus      = $OverallStatus
        Failed             = $FailedCount
        Blocked            = $BlockedCount
        Warning            = $WarningCount
        WaitingPropagation = $WaitingPropagationCount
        ValidatingResult   = $ValidatedCount
        Completed          = $CompletedCount
        Counts             = $Counts
        Reports            = [PSCustomObject]@{
            Markdown   = $ReportPath
            Json       = $SummaryPath
            Log        = $LogPath
            Transcript = $TranscriptPath
        }
        AllowedStates      = $AllowedStates
        Records            = @($ValidationRecords)
    }

    $ReportLines = @(
        "# LAB Validation Report - AMB Logistics",
        "",
        "- Generated: $($Summary.GeneratedAt)",
        "- Mode: $($Summary.Mode)",
        "- OverallStatus: $OverallStatus",
        "- Failed: $FailedCount",
        "- Blocked: $BlockedCount",
        "- Warning: $WarningCount",
        "- WaitingPropagation: $WaitingPropagationCount",
        "- ValidatingResult: $ValidatedCount",
        "- Completed: $CompletedCount",
        "",
        "## Target Counts",
        "",
        "| Matrix | Count |",
        "| --- | ---: |",
        "| Users | $($Counts.Users) |",
        "| Groups | $($Counts.Groups) |",
        "| Mailboxes | $($Counts.Mailboxes) |",
        "| Permissions | $($Counts.Permissions) |",
        "| Licenses | $($Counts.Licenses) |",
        "",
        "## Validation Records",
        "",
        "| Status | Scope | Message | Reference |",
        "| --- | --- | --- | --- |"
    )

    foreach ($Record in $ValidationRecords) {
        $Message = $Record.Message -replace "\|", "/"
        $ReportLines += "| $($Record.Status) | $($Record.Scope) | $Message | $($Record.Reference) |"
    }

    $ReportLines += @(
        "",
        "## LAB Boundary",
        "",
        "Validation is schema and relationship only. No tenant connection, production retry, infinite loop, delete action, or live permission reconciliation is performed by this report."
    )

    $ReportLines | Set-Content -Path $ReportPath -Encoding UTF8
    $Summary | ConvertTo-Json -Depth 8 | Set-Content -Path $SummaryPath -Encoding UTF8
    @(
        "GeneratedAt=$($Summary.GeneratedAt)",
        "Mode=$($Summary.Mode)",
        "OverallStatus=$OverallStatus",
        "Failed=$FailedCount",
        "Blocked=$BlockedCount",
        "Warning=$WarningCount",
        "WaitingPropagation=$WaitingPropagationCount",
        "ValidatingResult=$ValidatedCount",
        "Completed=$CompletedCount",
        "Report=$ReportPath",
        "Summary=$SummaryPath",
        "Transcript=$TranscriptPath"
    ) | Set-Content -Path $LogPath -Encoding UTF8

    Write-Host ""
    Write-Host "Target User Count:        $($Counts.Users)"
    Write-Host "Target Group Count:       $($Counts.Groups)"
    Write-Host "Target Mailbox Count:     $($Counts.Mailboxes)"
    Write-Host "Target Permission Count:  $($Counts.Permissions)"
    Write-Host "Target License Count:     $($Counts.Licenses)"
    Write-Host ""
    Write-Host "Report:     $ReportPath"
    Write-Host "Summary:    $SummaryPath"
    Write-Host "Log:        $LogPath"
    Write-Host "Transcript: $TranscriptPath"
    Write-Host ""
    Write-Host "Status: $OverallStatus" -ForegroundColor Cyan
}
finally {
    if ($TranscriptStarted) {
        Stop-Transcript | Out-Null
    }
}
