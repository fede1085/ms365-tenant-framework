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
    [String]$TenantId,
    [String]$TenantDomain,
    [String]$ProtectedGlobalAdminObjectId,
    [Switch]$LiveValidation
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

$AllowedStates = @(
    "VALIDATING",
    "VALIDATING_RESULT",
    "READY",
    "SKIPPED",
    "SKIPPED_PROTECTED",
    "COMPLETED",
    "WARNING",
    "FAILED",
    "BLOCKED"
)

$ValidationRecords = New-Object System.Collections.Generic.List[Object]
$FailedCount = 0
$BlockedCount = 0
$WarningCount = 0
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
        "VALIDATING_RESULT" { $script:ValidatedCount++ }
        "COMPLETED" { $script:CompletedCount++ }
    }

    $Color = "White"
    if ($Status -in @("FAILED", "BLOCKED")) { $Color = "Red" }
    elseif ($Status -in @("WARNING", "SKIPPED_PROTECTED")) { $Color = "Yellow" }
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

function Test-ScriptContains {
    Param(
        [String]$ScriptName,
        [String]$Pattern,
        [String]$Success,
        [String]$Failure
    )

    $ScriptPath = Join-Path $ScriptRoot $ScriptName
    $ScriptText = Get-Content -LiteralPath $ScriptPath -Raw
    if ($ScriptText -match $Pattern) {
        Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $ScriptName -Message $Success -Reference $ScriptName
    } else {
        Add-ValidationRecord -Status "BLOCKED" -Scope $ScriptName -Message $Failure -Reference $ScriptName
    }
}

function Resolve-GroupMatrixRow {
    Param([Object]$Permission)
    return @($script:Groups | Where-Object {
        $_.DisplayName -eq $Permission.ObjectName -or
        $_.PrimarySMTP -eq $Permission.TargetAddress -or
        $_.MailNickname -eq $Permission.TargetAddress
    } | Select-Object -First 1)
}

function Resolve-MailboxMatrixRow {
    Param([Object]$Permission)
    return @($script:Mailboxes | Where-Object {
        $_.DisplayName -eq $Permission.ObjectName -or
        $_.TargetAddress -eq $Permission.TargetAddress -or
        $_.Alias -eq $Permission.TargetAddress
    } | Select-Object -First 1)
}

function Invoke-StaticValidation {
    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "LAB-Protected-Objects.ps1 exists and was imported fail-closed." -Reference $ProtectedObjectsPath
    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "AMB protected UPNs are present: $($ProtectedSummary.ProtectedUPNs -join ', ')." -Reference "LAB-Protected-Objects.ps1"
    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "AMB protected aliases are present: $($ProtectedSummary.ProtectedAliases -join ', ')." -Reference "LAB-Protected-Objects.ps1"
    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "AMB protected display names are present: $($ProtectedSummary.ProtectedDisplayNames -join ', ')." -Reference "LAB-Protected-Objects.ps1"
    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "AMB protected roles are present: $($ProtectedSummary.ProtectedRoles -join ', ')." -Reference "LAB-Protected-Objects.ps1"
    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "SKIPPED_PROTECTED is supported by LAB validation states." -Reference "AUT-SYS-001"

    if ($ProtectedSummary.ObjectIdResolved) {
        Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedObjectPolicy" -Message "At least one protected ObjectId value is present." -Reference "LAB-Protected-Objects.ps1"
    } else {
        Add-ValidationRecord -Status "WARNING" -Scope "ProtectedObjectPolicy" -Message "Protected ObjectId values unresolved; protection continues by UPN, alias, display name, and role." -Reference "LAB-Protected-Objects.ps1"
    }

    foreach ($ScriptName in @("LAB-Run-Project.ps1", "LAB-Deploy-Tenant.ps1", "LAB-Create-Users.ps1", "LAB-Create-Groups.ps1", "LAB-Create-Mailboxes.ps1", "LAB-Apply-Permissions.ps1", "LAB-Validation-Report.ps1")) {
        Test-ScriptContains -ScriptName $ScriptName -Pattern "LAB-Protected-Objects\.ps1[\s\S]*Execution blocked" -Success "Imports protected-object policy and fails closed if missing." -Failure "Protected-object policy import or fail-closed guard is missing."
    }

    foreach ($ScriptName in @("LAB-Create-Users.ps1", "LAB-Create-Groups.ps1", "LAB-Create-Mailboxes.ps1", "LAB-Apply-Permissions.ps1")) {
        Test-ScriptContains -ScriptName $ScriptName -Pattern "Assert-LabNotProtectedObject[\s\S]*(New-MgUser|Update-MgUser|New-MgGroup|Update-MgGroup|New-Mailbox|Set-Mailbox|Set-User|Add-MailboxPermission|Add-RecipientPermission|New-MgGroupMemberByRef|New-MgGroupOwnerByRef)" -Success "Real write commands are protected by Assert-LabNotProtectedObject or equivalent guard." -Failure "Protected-object checks before write actions are missing."
    }

    Test-ScriptContains -ScriptName "LAB-Deploy-Tenant.ps1" -Pattern "License assignment is explicitly skipped" -Success "License assignment is explicitly skipped by the orchestrator." -Failure "License assignment skip statement is missing."
    Test-ScriptContains -ScriptName "LAB-Create-Users.ps1" -Pattern "License assignment skipped" -Success "User creation path does not assign licenses." -Failure "User creation path does not clearly skip license assignment."
    Test-ScriptContains -ScriptName "LAB-Run-Project.ps1" -Pattern "I UNDERSTAND THIS WILL MODIFY THE TENANT" -Success "Execute mode requires the hard confirmation phrase." -Failure "Hard confirmation phrase is missing."

    $MatrixSchemas = @{
        "MTX-USERS.csv"       = @("UserID", "DisplayName", "FirstName", "LastName", "UserPrincipalName", "MailNickname", "Department", "JobTitle", "UsageLocation", "LicenseSKU", "PasswordProfile", "AccountEnabled")
        "MTX-GROUPS.csv"      = @("GroupID", "DisplayName", "GroupType", "MailNickname", "PrimarySMTP", "Department", "Description", "OwnerUPN", "MailEnabled", "SecurityEnabled")
        "MTX-MAILBOXES.csv"   = @("MailboxID", "DisplayName", "Alias", "TargetAddress", "Department", "Purpose", "OwnerUPN", "Enabled")
        "MTX-PERMISSIONS.csv" = @("PermissionID", "ObjectType", "ObjectName", "TargetAddress", "UserUPN", "AccessType", "RoleScope", "Enabled")
        "MTX-LICENSES.csv"    = @("LicenseID", "UserPrincipalName", "LicenseSKU", "UsageLocation", "AssignmentState", "Notes")
    }
    $OptionalMatrixSchemas = @{
        "MTX-TEAMS.csv"             = @("TeamID", "DisplayName", "GroupMailNickname", "PrimarySMTP", "OwnerUPN", "Visibility", "Enabled")
        "MTX-CHANNELS.csv"          = @("ChannelID", "TeamID", "TeamDisplayName", "ChannelName", "ChannelType", "Enabled")
        "MTX-SITES.csv"             = @("SiteID", "SiteName", "SiteUrl", "SiteType", "OwnerUPN", "Enabled")
        "MTX-LIBRARIES.csv"         = @("LibraryID", "SiteID", "LibraryName", "LibraryType", "OwnerUPN", "Enabled")
        "MTX-PROTECTED-OBJECTS.csv" = @("ProtectedObjectID", "UserPrincipalName", "DisplayName", "Alias", "ObjectId", "RoleTitle", "ProtectionReason", "MutationPolicy", "Notes")
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

    foreach ($MatrixName in $OptionalMatrixSchemas.Keys) {
        $MatrixPath = Join-Path $MTXDir $MatrixName
        if (-not (Test-Path -LiteralPath $MatrixPath)) {
            Add-ValidationRecord -Status "SKIPPED" -Scope $MatrixName -Message "Optional matrix not present; workload remains unmodeled for LAB validation." -Reference $MatrixPath
            continue
        }

        Add-ValidationRecord -Status "VALIDATING" -Scope $MatrixName -Message "Checking optional file and schema." -Reference $MatrixPath
        $Rows = @(Import-Csv $MatrixPath)
        $MatrixData[$MatrixName] = $Rows
        [void](Test-RequiredColumns -MatrixName $MatrixName -Rows $Rows -RequiredColumns $OptionalMatrixSchemas[$MatrixName])
    }

    if (-not ($MatrixData.ContainsKey("MTX-USERS.csv") -and $MatrixData.ContainsKey("MTX-GROUPS.csv") -and $MatrixData.ContainsKey("MTX-MAILBOXES.csv") -and $MatrixData.ContainsKey("MTX-PERMISSIONS.csv"))) {
        Add-ValidationRecord -Status "BLOCKED" -Scope "StaticValidation" -Message "One or more required MTX files are missing; relationship validation skipped." -Reference $MTXDir
        return $MatrixData
    }

    $script:Users = @($MatrixData["MTX-USERS.csv"])
    $script:Groups = @($MatrixData["MTX-GROUPS.csv"])
    $script:Mailboxes = @($MatrixData["MTX-MAILBOXES.csv"])
    $script:Permissions = @($MatrixData["MTX-PERMISSIONS.csv"])

    $UserByUPN = @{}
    foreach ($User in $script:Users) {
        $UserByUPN[$User.UserPrincipalName] = $User
        $UserProtection = Assert-LabNotProtectedObject -InputObject $User -ObjectType "User" -ObjectName $User.UserPrincipalName -AttemptedAction "Static validation"
        if ($UserProtection.IsProtected) {
            Add-ValidationRecord -Status "SKIPPED_PROTECTED" -Scope $User.UserID -Message "Protected AMB identity appears in MTX user data and is protected from mutation: $($User.UserPrincipalName)." -Reference "MTX-USERS.csv"
        }
    }

    foreach ($Group in $script:Groups) {
        if (-not [string]::IsNullOrWhiteSpace($Group.OwnerUPN) -and -not $UserByUPN.ContainsKey($Group.OwnerUPN)) {
            Add-ValidationRecord -Status "WARNING" -Scope $Group.GroupID -Message "Group owner UPN does not resolve to MTX-USERS UserPrincipalName: $($Group.OwnerUPN)." -Reference "MTX-GROUPS.csv"
        }
    }

    if ($MatrixData.ContainsKey("MTX-LICENSES.csv")) {
        foreach ($License in @($MatrixData["MTX-LICENSES.csv"])) {
            if (-not $UserByUPN.ContainsKey($License.UserPrincipalName)) {
                Add-ValidationRecord -Status "WARNING" -Scope $License.LicenseID -Message "License UserPrincipalName does not resolve to MTX-USERS: $($License.UserPrincipalName)." -Reference "MTX-LICENSES.csv"
            }
            $LicenseProtection = Assert-LabNotProtectedObject -InputObject ([PSCustomObject]@{ UserPrincipalName = $License.UserPrincipalName }) -ObjectType "LicensePrincipal" -ObjectName $License.UserPrincipalName -AttemptedAction "Static validation"
            if ($LicenseProtection.IsProtected) {
                Add-ValidationRecord -Status "SKIPPED_PROTECTED" -Scope $License.LicenseID -Message "Protected identity license row is load/count only and will not be assigned by LAB runtime: $($License.UserPrincipalName)." -Reference "MTX-LICENSES.csv"
            }
        }
    }

    foreach ($Mailbox in $script:Mailboxes) {
        if ($Mailbox.Enabled -notin @("True", "False")) {
            Add-ValidationRecord -Status "WARNING" -Scope $Mailbox.MailboxID -Message "Enabled must be True or False: $($Mailbox.Enabled)." -Reference "MTX-MAILBOXES.csv"
        }
    }

    foreach ($Permission in $script:Permissions) {
        if ($Permission.Enabled -ne "True") {
            continue
        }
        $PrincipalProtection = Assert-LabNotProtectedObject -InputObject ([PSCustomObject]@{ UserPrincipalName = $Permission.UserUPN }) -ObjectType "PermissionPrincipal" -ObjectName $Permission.UserUPN -AttemptedAction "Static validation"
        if ($PrincipalProtection.IsProtected) {
            Add-ValidationRecord -Status "SKIPPED_PROTECTED" -Scope $Permission.PermissionID -Message "Permission principal is protected and will be skipped by LAB permissions runtime: $($Permission.UserUPN)." -Reference "MTX-PERMISSIONS.csv"
        }
        if ($Permission.ObjectType -eq "SharedMailbox" -and (Resolve-MailboxMatrixRow $Permission).Count -eq 0) {
            Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "Shared mailbox permission target cannot be resolved from MTX." -Reference "MTX-PERMISSIONS.csv"
        }
        if ($Permission.ObjectType -in @("M365Group", "Team", "SecurityGroup") -and (Resolve-GroupMatrixRow $Permission).Count -eq 0) {
            Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "Group permission target cannot be resolved from MTX." -Reference "MTX-PERMISSIONS.csv"
        }
    }

    if ($MatrixData.ContainsKey("MTX-TEAMS.csv") -and $MatrixData.ContainsKey("MTX-CHANNELS.csv")) {
        $EnabledTeams = @($MatrixData["MTX-TEAMS.csv"] | Where-Object { $_.Enabled -eq "True" })
        foreach ($Channel in @($MatrixData["MTX-CHANNELS.csv"] | Where-Object { $_.Enabled -eq "True" })) {
            $TeamMatches = @($EnabledTeams | Where-Object {
                $_.TeamID -eq $Channel.TeamID -or $_.DisplayName -eq $Channel.TeamDisplayName
            })
            if ($TeamMatches.Count -eq 0) {
                Add-ValidationRecord -Status "WARNING" -Scope $Channel.ChannelID -Message "Channel does not resolve to an enabled MTX-TEAMS row." -Reference "MTX-CHANNELS.csv"
            }
        }
    }

    if ($MatrixData.ContainsKey("MTX-SITES.csv") -and $MatrixData.ContainsKey("MTX-LIBRARIES.csv")) {
        $EnabledSites = @($MatrixData["MTX-SITES.csv"] | Where-Object { $_.Enabled -eq "True" })
        foreach ($Library in @($MatrixData["MTX-LIBRARIES.csv"] | Where-Object { $_.Enabled -eq "True" })) {
            $SiteMatches = @($EnabledSites | Where-Object { $_.SiteID -eq $Library.SiteID })
            if ($SiteMatches.Count -eq 0) {
                Add-ValidationRecord -Status "WARNING" -Scope $Library.LibraryID -Message "Library does not resolve to an enabled MTX-SITES row." -Reference "MTX-LIBRARIES.csv"
            }
        }
    }

    Add-ValidationRecord -Status "COMPLETED" -Scope "StaticValidation" -Message "Files, schemas, imports, protected policy, and command guards validated without tenant connection." -Reference "AUT-SYS-001"
    return $MatrixData
}

function Invoke-LiveValidation {
    Param([Hashtable]$MatrixData)

    if (-not $LiveValidation) {
        Add-ValidationRecord -Status "SKIPPED" -Scope "LiveValidation" -Message "Live validation not requested; no Graph or Exchange tenant validation performed." -Reference "Use -LiveValidation"
        return
    }

    if ([string]::IsNullOrWhiteSpace($TenantId) -or [string]::IsNullOrWhiteSpace($TenantDomain)) {
        Add-ValidationRecord -Status "BLOCKED" -Scope "LiveValidation" -Message "TenantId and TenantDomain are required for live validation." -Reference "LAB-Validation-Report.ps1"
        return
    }

    $Context = Get-MgContext
    if ($null -eq $Context -or $Context.TenantId -ne $TenantId) {
        Connect-MgGraph -TenantId $TenantId
        $Context = Get-MgContext
    }
    if ($null -eq $Context -or $Context.TenantId -ne $TenantId) {
        Add-ValidationRecord -Status "BLOCKED" -Scope "LiveValidation" -Message "Connected Graph tenant does not match target tenant." -Reference $TenantId
        return
    }

    try {
        Get-ConnectionInformation -ErrorAction Stop | Out-Null
    } catch {
        Connect-ExchangeOnline -Organization $TenantDomain -ShowBanner:$false
    }

    foreach ($ProtectedUPN in $ProtectedSummary.ProtectedUPNs) {
        $ProtectedUser = Get-MgUser -UserId $ProtectedUPN -Property "id,displayName,userPrincipalName,accountEnabled,proxyAddresses,assignedLicenses" -ErrorAction SilentlyContinue
        if ($ProtectedUser) {
            Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "ProtectedIdentity" -Message "Protected AMB identity exists: $ProtectedUPN; enabled state '$($ProtectedUser.AccountEnabled)'." -Reference "Get-MgUser"
            if ($ProtectedUser.AccountEnabled -ne $true) {
                Add-ValidationRecord -Status "FAILED" -Scope "ProtectedIdentity" -Message "Protected AMB identity is not enabled: $ProtectedUPN." -Reference "Get-MgUser"
            }
        } else {
            Add-ValidationRecord -Status "FAILED" -Scope "ProtectedIdentity" -Message "Protected AMB identity was not found: $ProtectedUPN." -Reference "Get-MgUser"
        }
    }

    foreach ($User in @($MatrixData["MTX-USERS.csv"])) {
        $TenantUser = Get-MgUser -UserId $User.UserPrincipalName -ErrorAction SilentlyContinue
        if ($TenantUser) {
            Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $User.UserID -Message "User exists: $($User.UserPrincipalName)." -Reference "Get-MgUser"
        } else {
            Add-ValidationRecord -Status "WARNING" -Scope $User.UserID -Message "User missing: $($User.UserPrincipalName)." -Reference "Get-MgUser"
        }
    }

    foreach ($Group in @($MatrixData["MTX-GROUPS.csv"])) {
        $EscapedNickname = $Group.MailNickname.Replace("'", "''")
        $TenantGroup = @(Get-MgGroup -Filter "mailNickname eq '$EscapedNickname'" -ErrorAction SilentlyContinue | Select-Object -First 1)
        if ($TenantGroup.Count -gt 0) {
            Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $Group.GroupID -Message "Group exists: $($Group.DisplayName)." -Reference "Get-MgGroup"
        } else {
            Add-ValidationRecord -Status "WARNING" -Scope $Group.GroupID -Message "Group missing: $($Group.DisplayName)." -Reference "Get-MgGroup"
        }
    }

    foreach ($Mailbox in @($MatrixData["MTX-MAILBOXES.csv"] | Where-Object { $_.Enabled -eq "True" })) {
        $TenantMailbox = Get-Mailbox -Identity $Mailbox.TargetAddress -ErrorAction SilentlyContinue
        if ($TenantMailbox) {
            Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $Mailbox.MailboxID -Message "Shared mailbox exists: $($Mailbox.TargetAddress)." -Reference "Get-Mailbox"
        } else {
            Add-ValidationRecord -Status "WARNING" -Scope $Mailbox.MailboxID -Message "Shared mailbox missing: $($Mailbox.TargetAddress)." -Reference "Get-Mailbox"
        }
    }

    foreach ($Permission in @($MatrixData["MTX-PERMISSIONS.csv"] | Where-Object { $_.Enabled -eq "True" })) {
        if ($Permission.ObjectType -eq "SharedMailbox") {
            if ($Permission.AccessType -eq "FullAccess") {
                $Existing = @(Get-MailboxPermission -Identity $Permission.TargetAddress -User $Permission.UserUPN -ErrorAction SilentlyContinue | Where-Object { $_.AccessRights -contains "FullAccess" -and -not $_.Deny })
                if ($Existing.Count -gt 0) {
                    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $Permission.PermissionID -Message "FullAccess exists." -Reference "Get-MailboxPermission"
                } else {
                    Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "FullAccess missing." -Reference "Get-MailboxPermission"
                }
            } elseif ($Permission.AccessType -eq "SendAs") {
                $Existing = @(Get-RecipientPermission -Identity $Permission.TargetAddress -Trustee $Permission.UserUPN -ErrorAction SilentlyContinue | Where-Object { $_.AccessRights -contains "SendAs" -and -not $_.Deny })
                if ($Existing.Count -gt 0) {
                    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $Permission.PermissionID -Message "SendAs exists." -Reference "Get-RecipientPermission"
                } else {
                    Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "SendAs missing." -Reference "Get-RecipientPermission"
                }
            } elseif ($Permission.AccessType -eq "SendOnBehalf") {
                $TenantMailbox = Get-Mailbox -Identity $Permission.TargetAddress -ErrorAction SilentlyContinue
                $Delegates = @($TenantMailbox.GrantSendOnBehalfTo | ForEach-Object { [string]$_ })
                if ($Delegates -contains $Permission.UserUPN) {
                    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $Permission.PermissionID -Message "SendOnBehalf exists." -Reference "Get-Mailbox"
                } else {
                    Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "SendOnBehalf missing or not visible by UPN." -Reference "Get-Mailbox"
                }
            }
        } elseif ($Permission.ObjectType -in @("M365Group", "Team", "SecurityGroup")) {
            $EscapedTarget = $Permission.TargetAddress.Replace("'", "''")
            $TenantGroup = @(Get-MgGroup -Filter "mailNickname eq '$EscapedTarget' or mail eq '$EscapedTarget' or displayName eq '$EscapedTarget'" -ErrorAction SilentlyContinue | Select-Object -First 1)
            $Principal = Get-MgUser -UserId $Permission.UserUPN -ErrorAction SilentlyContinue
            if ($TenantGroup.Count -eq 0 -or $null -eq $Principal) {
                Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "Group or principal missing for live permission validation." -Reference "Get-MgGroup/Get-MgUser"
                continue
            }

            if ($Permission.AccessType -eq "Member") {
                $ExistingMembers = @(Get-MgGroupMember -GroupId $TenantGroup[0].Id -All -ErrorAction SilentlyContinue | Where-Object { $_.Id -eq $Principal.Id })
                if ($ExistingMembers.Count -gt 0) {
                    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $Permission.PermissionID -Message "Group member exists." -Reference "Get-MgGroupMember"
                } else {
                    Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "Group member missing." -Reference "Get-MgGroupMember"
                }
            } elseif ($Permission.AccessType -eq "Owner") {
                $ExistingOwners = @(Get-MgGroupOwner -GroupId $TenantGroup[0].Id -All -ErrorAction SilentlyContinue | Where-Object { $_.Id -eq $Principal.Id })
                if ($ExistingOwners.Count -gt 0) {
                    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope $Permission.PermissionID -Message "Group owner exists." -Reference "Get-MgGroupOwner"
                } else {
                    Add-ValidationRecord -Status "WARNING" -Scope $Permission.PermissionID -Message "Group owner missing." -Reference "Get-MgGroupOwner"
                }
            }
        }
    }

    Add-ValidationRecord -Status "VALIDATING_RESULT" -Scope "Licenses" -Message "Runtime does not implement license assignment; no license write command is validated." -Reference "No Set-MgUserLicense path"
    Add-ValidationRecord -Status "COMPLETED" -Scope "LiveValidation" -Message "Live tenant reality validation completed for supported object types." -Reference "Graph/Exchange read checks"
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "LAB VALIDATION REPORT - AMB LOGISTICS" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Mode: $(if ($LiveValidation) { 'LIVE-VALIDATION' } else { 'STATIC-VALIDATION' })"

$MatrixData = Invoke-StaticValidation
Invoke-LiveValidation -MatrixData $MatrixData

$OverallStatus = "COMPLETED"
if ($FailedCount -gt 0) { $OverallStatus = "FAILED" }
elseif ($BlockedCount -gt 0) { $OverallStatus = "BLOCKED" }
elseif ($WarningCount -gt 0) { $OverallStatus = "WARNING" }

Write-Host ""
Write-Host "Status: $OverallStatus" -ForegroundColor Cyan
Write-Host "Failed: $FailedCount; Blocked: $BlockedCount; Warning: $WarningCount; Validated: $ValidatedCount; Completed: $CompletedCount"
