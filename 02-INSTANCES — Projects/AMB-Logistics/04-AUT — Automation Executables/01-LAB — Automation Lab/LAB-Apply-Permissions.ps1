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
    [String]$ProtectedGlobalAdminObjectId
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

$PermissionPath = Join-Path $MTXDir "MTX-PERMISSIONS.csv"
$UserPath = Join-Path $MTXDir "MTX-USERS.csv"
$GroupPath = Join-Path $MTXDir "MTX-GROUPS.csv"
$MailboxPath = Join-Path $MTXDir "MTX-MAILBOXES.csv"

foreach ($Path in @($PermissionPath, $UserPath, $GroupPath, $MailboxPath)) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Required MTX file not found: $Path"
    }
}

$Permissions = @(Import-Csv $PermissionPath)
$Users = @(Import-Csv $UserPath)
$Groups = @(Import-Csv $GroupPath)
$Mailboxes = @(Import-Csv $MailboxPath)

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

function Escape-LabODataString {
    Param([String]$Value)
    return $Value.Replace("'", "''")
}

function Resolve-GroupMatrixRow {
    Param([Object]$Permission)
    return @($Groups | Where-Object {
        $_.DisplayName -eq $Permission.ObjectName -or
        $_.PrimarySMTP -eq $Permission.TargetAddress -or
        $_.MailNickname -eq $Permission.TargetAddress
    } | Select-Object -First 1)
}

function Resolve-MailboxMatrixRow {
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
            $Mailbox = Resolve-MailboxMatrixRow $Permission
            if ($Mailbox.Count -eq 0) { return $null }
            return $Mailbox[0].TargetAddress
        }
        { $_ -in @("M365Group", "Team") } {
            $Group = Resolve-GroupMatrixRow $Permission
            if ($Group.Count -eq 0) { return $null }
            return $Group[0].PrimarySMTP
        }
        "SecurityGroup" {
            $Group = Resolve-GroupMatrixRow $Permission
            if ($Group.Count -eq 0) { return $null }
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

function Resolve-LabGraphGroup {
    Param([Object]$Permission)

    $GroupRow = Resolve-GroupMatrixRow $Permission
    $Target = $Permission.TargetAddress
    if ($GroupRow.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($GroupRow[0].MailNickname)) {
        $Target = $GroupRow[0].MailNickname
    }

    $EscapedTarget = Escape-LabODataString $Target
    $EscapedName = Escape-LabODataString $Permission.ObjectName
    return @(Get-MgGroup -Filter "mailNickname eq '$EscapedTarget' or mail eq '$EscapedTarget' or displayName eq '$EscapedName'" -ErrorAction SilentlyContinue | Select-Object -First 1)
}

$SchemasReady = $true
$SchemasReady = (Test-RequiredColumns $Permissions @("PermissionID", "ObjectType", "ObjectName", "TargetAddress", "UserUPN", "AccessType", "RoleScope", "Enabled") "MTX-PERMISSIONS.csv") -and $SchemasReady
$SchemasReady = (Test-RequiredColumns $Users @("UserID", "DisplayName", "FirstName", "LastName", "UserPrincipalName", "MailNickname", "Department", "JobTitle", "UsageLocation", "LicenseSKU", "PasswordProfile", "AccountEnabled") "MTX-USERS.csv") -and $SchemasReady
$SchemasReady = (Test-RequiredColumns $Groups @("GroupID", "DisplayName", "GroupType", "MailNickname", "PrimarySMTP", "Department", "Description", "OwnerUPN", "MailEnabled", "SecurityEnabled") "MTX-GROUPS.csv") -and $SchemasReady
$SchemasReady = (Test-RequiredColumns $Mailboxes @("MailboxID", "DisplayName", "Alias", "TargetAddress", "Department", "Purpose", "OwnerUPN", "Enabled") "MTX-MAILBOXES.csv") -and $SchemasReady
if (-not $SchemasReady) {
    return
}

$AllowedObjectTypes = @("SharedMailbox", "M365Group", "Team", "SecurityGroup")
$AllowedAccessTypes = @("FullAccess", "SendAs", "SendOnBehalf", "Member", "Owner")
$ExchangeAccessTypes = @("FullAccess", "SendAs", "SendOnBehalf")
$MembershipAccessTypes = @("Member", "Owner")

$UserUPNs = @{}
foreach ($User in $Users) {
    $UserUPNs[$User.UserPrincipalName] = $true
}

foreach ($Perm in $Permissions) {
    if ($Perm.Enabled -ne "True") {
        Write-Host "[SKIPPED] $($Perm.PermissionID) disabled in MTX."
        continue
    }

    $PermissionTarget = [PSCustomObject]@{
        ObjectName    = $Perm.ObjectName
        TargetAddress = $Perm.TargetAddress
    }
    $PermissionProtection = Assert-LabNotProtectedObject -InputObject $PermissionTarget -ObjectType "PermissionTarget" -ObjectName $Perm.PermissionID -AttemptedAction "Apply permission"
    $PrincipalProtection = Assert-LabNotProtectedObject -InputObject ([PSCustomObject]@{ UserPrincipalName = $Perm.UserUPN }) -ObjectType "PermissionPrincipal" -ObjectName $Perm.UserUPN -AttemptedAction "Add explicit non-destructive permission"

    if ($PermissionProtection.IsProtected) {
        Write-Host "[BLOCKED] $($Perm.PermissionID) protected target is ambiguous for permission mutation: $($PermissionProtection.Reason)" -ForegroundColor Red
        continue
    }
    if ($PrincipalProtection.IsProtected) {
        Write-Host "[$($PrincipalProtection.State)] $($Perm.PermissionID) protected principal is not mutated by LAB permissions runtime: $($PrincipalProtection.Reason)" -ForegroundColor Yellow
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

    $Plan = "{0}: {1} -> {2} on {3} ({4})" -f $Perm.PermissionID, $Perm.UserUPN, $Perm.AccessType, $Perm.TargetAddress, $Perm.ObjectType
    if ($DryRun) {
        Write-Host "[READY][DRY-RUN] $Plan" -ForegroundColor Gray
        continue
    }

    switch ($Perm.ObjectType) {
        "SharedMailbox" {
            $Mailbox = Get-Mailbox -Identity $Perm.TargetAddress -ErrorAction SilentlyContinue
            if (-not $Mailbox) {
                Write-Host "[BLOCKED] $($Perm.PermissionID) shared mailbox not found: $($Perm.TargetAddress)" -ForegroundColor Red
                continue
            }

            [void](Assert-LabNotProtectedObject -InputObject $Mailbox -ObjectType "SharedMailbox" -ObjectName $Perm.TargetAddress -AttemptedAction "Add mailbox permission" -ThrowOnProtected)

            if ($Perm.AccessType -eq "FullAccess") {
                $Existing = @(Get-MailboxPermission -Identity $Perm.TargetAddress -User $Perm.UserUPN -ErrorAction SilentlyContinue | Where-Object { $_.AccessRights -contains "FullAccess" -and -not $_.Deny })
                if ($Existing.Count -gt 0) {
                    Write-Host "[SKIPPED] $($Perm.PermissionID) FullAccess already present." -ForegroundColor Yellow
                    continue
                }
                Add-MailboxPermission -Identity $Perm.TargetAddress -User $Perm.UserUPN -AccessRights FullAccess -InheritanceType All -AutoMapping:$false
                Write-Host "[EXECUTED] $($Perm.PermissionID) FullAccess added." -ForegroundColor Green
            } elseif ($Perm.AccessType -eq "SendAs") {
                $Existing = @(Get-RecipientPermission -Identity $Perm.TargetAddress -Trustee $Perm.UserUPN -ErrorAction SilentlyContinue | Where-Object { $_.AccessRights -contains "SendAs" -and -not $_.Deny })
                if ($Existing.Count -gt 0) {
                    Write-Host "[SKIPPED] $($Perm.PermissionID) SendAs already present." -ForegroundColor Yellow
                    continue
                }
                Add-RecipientPermission -Identity $Perm.TargetAddress -Trustee $Perm.UserUPN -AccessRights SendAs -Confirm:$false
                Write-Host "[EXECUTED] $($Perm.PermissionID) SendAs added." -ForegroundColor Green
            } elseif ($Perm.AccessType -eq "SendOnBehalf") {
                $ExistingMailbox = Get-Mailbox -Identity $Perm.TargetAddress
                $ExistingDelegates = @($ExistingMailbox.GrantSendOnBehalfTo | ForEach-Object { [string]$_ })
                if ($ExistingDelegates -contains $Perm.UserUPN) {
                    Write-Host "[SKIPPED] $($Perm.PermissionID) SendOnBehalf already present." -ForegroundColor Yellow
                    continue
                }
                Set-Mailbox -Identity $Perm.TargetAddress -GrantSendOnBehalfTo @{ Add = $Perm.UserUPN }
                Write-Host "[EXECUTED] $($Perm.PermissionID) SendOnBehalf added." -ForegroundColor Green
            }
        }
        { $_ -in @("M365Group", "Team", "SecurityGroup") } {
            $Group = Resolve-LabGraphGroup $Perm
            if ($Group.Count -eq 0) {
                Write-Host "[BLOCKED] $($Perm.PermissionID) group not found: $($Perm.TargetAddress)" -ForegroundColor Red
                continue
            }
            $Group = $Group[0]
            [void](Assert-LabNotProtectedObject -InputObject $Group -ObjectType "Group" -ObjectName $Perm.TargetAddress -AttemptedAction "Add group permission" -ThrowOnProtected)

            $Principal = Get-MgUser -UserId $Perm.UserUPN -ErrorAction SilentlyContinue
            if ($null -eq $Principal) {
                Write-Host "[BLOCKED] $($Perm.PermissionID) user not found: $($Perm.UserUPN)" -ForegroundColor Red
                continue
            }

            if ($Perm.AccessType -eq "Member") {
                $ExistingMembers = @(Get-MgGroupMember -GroupId $Group.Id -All -ErrorAction SilentlyContinue | Where-Object { $_.Id -eq $Principal.Id })
                if ($ExistingMembers.Count -gt 0) {
                    Write-Host "[SKIPPED] $($Perm.PermissionID) member already present." -ForegroundColor Yellow
                    continue
                }
                New-MgGroupMemberByRef -GroupId $Group.Id -OdataId "https://graph.microsoft.com/v1.0/directoryObjects/$($Principal.Id)"
                Write-Host "[EXECUTED] $($Perm.PermissionID) group member added." -ForegroundColor Green
            } elseif ($Perm.AccessType -eq "Owner") {
                $ExistingOwners = @(Get-MgGroupOwner -GroupId $Group.Id -All -ErrorAction SilentlyContinue | Where-Object { $_.Id -eq $Principal.Id })
                if ($ExistingOwners.Count -gt 0) {
                    Write-Host "[SKIPPED] $($Perm.PermissionID) owner already present." -ForegroundColor Yellow
                    continue
                }
                New-MgGroupOwnerByRef -GroupId $Group.Id -OdataId "https://graph.microsoft.com/v1.0/directoryObjects/$($Principal.Id)"
                Write-Host "[EXECUTED] $($Perm.PermissionID) group owner added." -ForegroundColor Green
            }
        }
    }
}

Write-Host "Permission processing completed. No permissions were removed." -ForegroundColor Cyan
