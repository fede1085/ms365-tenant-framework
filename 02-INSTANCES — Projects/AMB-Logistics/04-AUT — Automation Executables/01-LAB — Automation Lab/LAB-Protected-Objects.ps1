<#
LAB / EXPERIMENTAL / NON-CANONICAL
Tenant-local runtime safety data
Semi-controlled execution supported
Not production-grade
No license assignment
Protected-object guarded
#>

$script:LabProtectedObjectPolicy = [PSCustomObject]@{
    ProtectedUPNs = @(
        "homelab@federicomosqueira0910.onmicrosoft.com"
    )
    ProtectedAliases = @(
        "global.admin@federicomosqueira.site",
        "hello@federicomosqueira.site"
    )
    ProtectedDisplayNames = @(
        "GLOBAL-Admin"
    )
    ProtectedObjectIds = @(
        "<UNKNOWN_OBJECT_ID_GLOBAL_ADMIN>"
    )
    ProtectedRoles = @(
        "Global Administrator"
    )
}

function Normalize-LabIdentityValue {
    Param(
        [AllowNull()][Object]$Value
    )

    if ($null -eq $Value) {
        return ""
    }

    return ([string]$Value).Trim().ToLowerInvariant()
}

function Test-LabValueInProtectedSet {
    Param(
        [AllowNull()][Object]$Value,
        [String[]]$ProtectedValues
    )

    $NormalizedValue = Normalize-LabIdentityValue $Value
    if ([string]::IsNullOrWhiteSpace($NormalizedValue)) {
        return $false
    }

    foreach ($ProtectedValue in $ProtectedValues) {
        $NormalizedProtectedValue = Normalize-LabIdentityValue $ProtectedValue
        if ($NormalizedValue -eq $NormalizedProtectedValue) {
            return $true
        }

        if ($NormalizedProtectedValue.Contains("@")) {
            $ProtectedMailNickname = ($NormalizedProtectedValue -split "@")[0]
            if ($NormalizedValue -eq $ProtectedMailNickname) {
                return $true
            }
        }
    }

    return $false
}

function Get-LabProtectedIdentityMatch {
    Param(
        [String]$UPN,
        [String]$DisplayName,
        [String]$Alias,
        [String]$ObjectId,
        [Object]$Role,
        [String]$MailNickname,
        [String]$PrimarySMTP
    )

    $Checks = @(
        @{ Field = "UPN"; Value = $UPN; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedUPNs },
        @{ Field = "DisplayName"; Value = $DisplayName; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedDisplayNames },
        @{ Field = "Alias"; Value = $Alias; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedAliases },
        @{ Field = "ObjectId"; Value = $ObjectId; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedObjectIds },
        @{ Field = "MailNickname"; Value = $MailNickname; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedAliases },
        @{ Field = "PrimarySMTP"; Value = $PrimarySMTP; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedAliases }
    )

    foreach ($Check in $Checks) {
        if (Test-LabValueInProtectedSet -Value $Check.Value -ProtectedValues $Check.ProtectedValues) {
            return [PSCustomObject]@{
                IsProtected  = $true
                MatchedField = $Check.Field
                MatchedValue = $Check.Value
                Reason       = "Matched protected $($Check.Field): $($Check.Value)"
            }
        }
    }

    foreach ($RoleValue in @($Role)) {
        if ($null -eq $RoleValue) {
            continue
        }

        foreach ($ExpandedRole in @([string]$RoleValue -split "[,;]")) {
            if (Test-LabValueInProtectedSet -Value $ExpandedRole -ProtectedValues $script:LabProtectedObjectPolicy.ProtectedRoles) {
                return [PSCustomObject]@{
                    IsProtected  = $true
                    MatchedField = "Role"
                    MatchedValue = $ExpandedRole
                    Reason       = "Matched protected Role: $ExpandedRole"
                }
            }
        }
    }

    return [PSCustomObject]@{
        IsProtected  = $false
        MatchedField = ""
        MatchedValue = ""
        Reason       = ""
    }
}

function Get-LabProtectedObjectMatch {
    Param(
        [AllowNull()][Object]$InputObject
    )

    if ($null -eq $InputObject) {
        return [PSCustomObject]@{
            IsProtected  = $false
            MatchedField = ""
            MatchedValue = ""
            Reason       = ""
        }
    }

    $FieldChecks = @(
        @{ Field = "UserPrincipalName"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedUPNs },
        @{ Field = "UPN"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedUPNs },
        @{ Field = "UserUPN"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedUPNs },
        @{ Field = "OwnerUPN"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedUPNs },
        @{ Field = "DisplayName"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedDisplayNames },
        @{ Field = "ObjectName"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedDisplayNames },
        @{ Field = "TargetAddress"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedAliases },
        @{ Field = "PrimarySMTP"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedAliases },
        @{ Field = "Alias"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedAliases },
        @{ Field = "MailNickname"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedAliases },
        @{ Field = "Id"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedObjectIds },
        @{ Field = "ObjectId"; ProtectedValues = $script:LabProtectedObjectPolicy.ProtectedObjectIds }
    )

    foreach ($Check in $FieldChecks) {
        $Value = $InputObject.($Check.Field)
        if (Test-LabValueInProtectedSet -Value $Value -ProtectedValues $Check.ProtectedValues) {
            return [PSCustomObject]@{
                IsProtected  = $true
                MatchedField = $Check.Field
                MatchedValue = $Value
                Reason       = "Matched protected $($Check.Field): $Value"
            }
        }
    }

    foreach ($RoleField in @("Role", "Roles")) {
        foreach ($RoleValue in @($InputObject.$RoleField)) {
            if ($null -eq $RoleValue) {
                continue
            }

            foreach ($ExpandedRole in @([string]$RoleValue -split "[,;]")) {
                if (Test-LabValueInProtectedSet -Value $ExpandedRole -ProtectedValues $script:LabProtectedObjectPolicy.ProtectedRoles) {
                    return [PSCustomObject]@{
                        IsProtected  = $true
                        MatchedField = $RoleField
                        MatchedValue = $ExpandedRole
                        Reason       = "Matched protected ${RoleField}: $ExpandedRole"
                    }
                }
            }
        }
    }

    return [PSCustomObject]@{
        IsProtected  = $false
        MatchedField = ""
        MatchedValue = ""
        Reason       = ""
    }
}

function Test-LabProtectedIdentity {
    Param(
        [String]$UPN,
        [String]$DisplayName,
        [String]$Alias,
        [String]$ObjectId,
        [Object]$Role,
        [String]$MailNickname,
        [String]$PrimarySMTP
    )

    $Match = Get-LabProtectedIdentityMatch -UPN $UPN -DisplayName $DisplayName -Alias $Alias -ObjectId $ObjectId -Role $Role -MailNickname $MailNickname -PrimarySMTP $PrimarySMTP
    return [bool]$Match.IsProtected
}

function Test-LabProtectedObject {
    Param(
        [AllowNull()][Object]$InputObject
    )

    $Match = Get-LabProtectedObjectMatch -InputObject $InputObject
    return [bool]$Match.IsProtected
}

function Assert-LabNotProtectedObject {
    Param(
        [AllowNull()][Object]$InputObject,
        [String]$ObjectType = "Object",
        [String]$ObjectName = "",
        [String]$AttemptedAction = "Mutate",
        [Switch]$ThrowOnProtected
    )

    $Match = Get-LabProtectedObjectMatch -InputObject $InputObject

    if (-not $Match.IsProtected) {
        return [PSCustomObject]@{
            State           = "READY"
            IsProtected     = $false
            ObjectType      = $ObjectType
            ObjectName      = $ObjectName
            AttemptedAction = $AttemptedAction
            Reason          = ""
        }
    }

    $ResolvedObjectName = if ([string]::IsNullOrWhiteSpace($ObjectName)) { "<unknown>" } else { $ObjectName }
    $Reason = "Protected object blocked. Type=$ObjectType; Name=$ResolvedObjectName; Action=$AttemptedAction; $($Match.Reason)"

    if ($ThrowOnProtected) {
        throw $Reason
    }

    return [PSCustomObject]@{
        State           = "SKIPPED_PROTECTED"
        IsProtected     = $true
        ObjectType      = $ObjectType
        ObjectName      = $ResolvedObjectName
        AttemptedAction = $AttemptedAction
        Reason          = $Reason
    }
}

function Get-LabProtectedObjectSummary {
    return [PSCustomObject]@{
        ProtectedUPNs         = $script:LabProtectedObjectPolicy.ProtectedUPNs
        ProtectedAliases     = $script:LabProtectedObjectPolicy.ProtectedAliases
        ProtectedDisplayNames = $script:LabProtectedObjectPolicy.ProtectedDisplayNames
        ProtectedObjectIds    = $script:LabProtectedObjectPolicy.ProtectedObjectIds
        ProtectedRoles        = $script:LabProtectedObjectPolicy.ProtectedRoles
        Boundary              = "LAB / EXPERIMENTAL / NON-CANONICAL; Semi-controlled execution supported; Not production-grade; No license assignment; Protected-object guarded"
    }
}
