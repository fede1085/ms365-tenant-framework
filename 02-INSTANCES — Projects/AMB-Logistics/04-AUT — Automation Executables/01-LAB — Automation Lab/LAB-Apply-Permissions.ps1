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

$PermissionPath = Join-Path $MTXDir "MTX-PERMISSIONS.csv"
$UserPath = Join-Path $MTXDir "MTX-USERS.csv"
$GroupPath = Join-Path $MTXDir "MTX-GROUPS.csv"
$MailboxPath = Join-Path $MTXDir "MTX-MAILBOXES.csv"

foreach ($Path in @($PermissionPath, $UserPath, $GroupPath, $MailboxPath)) {
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "[BLOCKED] Required MTX file not found: $Path" -ForegroundColor Red
        return
    }
}

$Permissions = Import-Csv $PermissionPath
$Users = Import-Csv $UserPath
$Groups = Import-Csv $GroupPath
$Mailboxes = Import-Csv $MailboxPath

function Test-RequiredColumns {
    Param(
        [Object[]]$Rows,
        [String[]]$RequiredColumns,
        [String]$Name
    )

    $Columns = @($Rows | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name -Unique)
    $MissingColumns = @($RequiredColumns | Where-Object { $_ -notin $Columns })
    if ($MissingColumns.Count -gt 0) {
        Write-Host "[BLOCKED] $Name missing required column(s): $($MissingColumns -join ', ')" -ForegroundColor Red
        return $false
    }
    return $true
}

$SchemasReady = $true
$SchemasReady = (Test-RequiredColumns $Permissions @("PermissionID", "ObjectType", "ObjectName", "TargetAddress", "UserUPN", "AccessType", "RoleScope", "Enabled") "MTX-PERMISSIONS.csv") -and $SchemasReady
$SchemasReady = (Test-RequiredColumns $Users @("UserID", "DisplayName", "FirstName", "LastName", "UserPrincipalName", "MailNickname", "Department", "JobTitle", "UsageLocation", "LicenseSKU", "PasswordProfile", "AccountEnabled") "MTX-USERS.csv") -and $SchemasReady
$SchemasReady = (Test-RequiredColumns $Groups @("GroupID", "DisplayName", "GroupType", "MailNickname", "PrimarySMTP", "Department", "Description", "OwnerUPN", "MailEnabled", "SecurityEnabled") "MTX-GROUPS.csv") -and $SchemasReady
$SchemasReady = (Test-RequiredColumns $Mailboxes @("MailboxID", "DisplayName", "Alias", "TargetAddress", "Department", "Purpose", "OwnerUPN", "Enabled") "MTX-MAILBOXES.csv") -and $SchemasReady
if (-not $SchemasReady) {
    return
}

$AllowedObjectTypes = @("SharedMailbox", "M365Group", "Team", "SharePointSite", "SecurityGroup")
$AllowedAccessTypes = @("FullAccess", "SendAs", "SendOnBehalf", "Member", "Owner", "Read", "Edit", "FullControl")
$ExchangeAccessTypes = @("FullAccess", "SendAs", "SendOnBehalf")
$MembershipAccessTypes = @("Member", "Owner")

$UserUPNs = @{}
foreach ($User in $Users) {
    $UserUPNs[$User.UserPrincipalName] = $true
}

function Resolve-Group {
    Param([Object]$Permission)

    return @($Groups | Where-Object {
        $_.DisplayName -eq $Permission.ObjectName -or
        $_.PrimarySMTP -eq $Permission.TargetAddress -or
        $_.MailNickname -eq $Permission.TargetAddress
    } | Select-Object -First 1)
}

function Resolve-Mailbox {
    Param([Object]$Permission)

    return @($Mailboxes | Where-Object {
        $_.DisplayName -eq $Permission.ObjectName -or
        $_.TargetAddress -eq $Permission.TargetAddress -or
        $_.Alias -eq $Permission.TargetAddress
    } | Select-Object -First 1)
}

function Get-ExpectedTargetAddress {
    Param([Object]$Permission)

    switch ($Permission.ObjectType) {
        "SharedMailbox" {
            $Mailbox = Resolve-Mailbox $Permission
            if ($Mailbox.Count -eq 0) { return $null }
            return $Mailbox[0].TargetAddress
        }
        { $_ -in @("M365Group", "Team") } {
            $Group = Resolve-Group $Permission
            if ($Group.Count -eq 0) { return $null }
            return $Group[0].PrimarySMTP
        }
        "SecurityGroup" {
            $Group = Resolve-Group $Permission
            if ($Group.Count -eq 0) { return $null }
            # Security groups are not mail-enabled in this tenant MTX, so no SMTP
            # address is expected. The LAB runtime uses MailNickname as the stable
            # execution identifier, falling back to DisplayName only if absent.
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

foreach ($Perm in $Permissions) {
    $State = "PENDING"

    if ($Perm.Enabled -ne "True") {
        Write-Host "[SKIPPED] $($Perm.PermissionID) disabled in MTX."
        continue
    }

    $State = "VALIDATING"
    $PermissionProtection = Assert-LabNotProtectedObject -InputObject $Perm -ObjectType "Permission" -ObjectName $Perm.PermissionID -AttemptedAction "Apply permission"
    $PrincipalProtection = Assert-LabNotProtectedObject -InputObject ([PSCustomObject]@{ UserPrincipalName = $Perm.UserUPN }) -ObjectType "PermissionPrincipal" -ObjectName $Perm.UserUPN -AttemptedAction "Grant or modify permission"
    if ($PermissionProtection.IsProtected -or $PrincipalProtection.IsProtected) {
        $State = "BLOCKED"
        $Reason = @($PermissionProtection.Reason, $PrincipalProtection.Reason) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        Write-Host "[$State] $($Perm.PermissionID) protected-object permission conflict: $($Reason -join '; ')" -ForegroundColor Red
        continue
    }

    $Problems = New-Object System.Collections.Generic.List[String]
    if ($Perm.ObjectType -notin $AllowedObjectTypes) {
        $Problems.Add("Invalid ObjectType '$($Perm.ObjectType)'")
    }
    if ($Perm.AccessType -notin $AllowedAccessTypes) {
        $Problems.Add("Invalid AccessType '$($Perm.AccessType)'")
    }
    if (-not $UserUPNs.ContainsKey($Perm.UserUPN)) {
        $Problems.Add("UserUPN not found in MTX-USERS.csv: $($Perm.UserUPN)")
    }

    $ExpectedTargetAddress = Get-ExpectedTargetAddress $Perm
    if ([string]::IsNullOrWhiteSpace($ExpectedTargetAddress)) {
        $Problems.Add("Target object not found in MTX data: $($Perm.ObjectName)")
    } elseif ($Perm.TargetAddress -ne $ExpectedTargetAddress) {
        $Problems.Add("TargetAddress '$($Perm.TargetAddress)' should be '$ExpectedTargetAddress'")
    }

    if ($Perm.ObjectType -eq "SharedMailbox" -and $Perm.AccessType -notin $ExchangeAccessTypes) {
        $Problems.Add("SharedMailbox permissions require Exchange access type: $($ExchangeAccessTypes -join ', ')")
    }
    if ($Perm.ObjectType -in @("M365Group", "Team", "SecurityGroup") -and $Perm.AccessType -notin $MembershipAccessTypes) {
        $Problems.Add("$($Perm.ObjectType) permissions require membership access type: $($MembershipAccessTypes -join ', ')")
    }

    if ($Problems.Count -gt 0) {
        Write-Host "[BLOCKED] $($Perm.PermissionID) $($Perm.ObjectType) $($Perm.AccessType): $($Problems -join '; ')" -ForegroundColor Red
        continue
    }

    $State = "READY"
    $Plan = "{0}: {1} -> {2} on {3} ({4})" -f $Perm.PermissionID, $Perm.UserUPN, $Perm.AccessType, $Perm.TargetAddress, $Perm.ObjectType

    if ($DryRun) {
        Write-Host "[READY][DRY-RUN] $Plan" -ForegroundColor Gray
        continue
    }

    switch ($Perm.ObjectType) {
        "SharedMailbox" {
            Write-Host "[READY] $Plan" -ForegroundColor Cyan
            Write-Host "        Prepared branch: verify existing Exchange permission, then Add-MailboxPermission/Add-RecipientPermission if missing." -ForegroundColor DarkCyan
        }
        { $_ -in @("M365Group", "Team", "SecurityGroup") } {
            Write-Host "[READY] $Plan" -ForegroundColor Cyan
            Write-Host "        Prepared branch: resolve group by TargetAddress, verify membership/owner, then Add-MgGroupMember/Add-MgGroupOwner if missing." -ForegroundColor DarkCyan
        }
        default {
            Write-Host "[WARNING] $($Perm.PermissionID) has no LAB execution branch for ObjectType $($Perm.ObjectType)." -ForegroundColor Yellow
        }
    }
}

Write-Host "Permission processing completed. LAB script performs validation and planning only; no fake success state is emitted." -ForegroundColor Cyan
