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

$CSVPath = Join-Path $MTXDir "MTX-GROUPS.csv"
if (-not (Test-Path $CSVPath)) {
    Write-Host "[!] Error: MTX-GROUPS.csv not found" -ForegroundColor Red
    return
}

$Groups = Import-Csv $CSVPath
# Runtime schema alignment: GroupID is semantic; GroupType, MailNickname,
# PrimarySMTP, OwnerUPN, MailEnabled, and SecurityEnabled are execution-facing.
$RequiredColumns = @("GroupID", "DisplayName", "GroupType", "MailNickname", "PrimarySMTP", "Department", "OwnerUPN", "MailEnabled", "SecurityEnabled", "Description")
$Columns = @($Groups | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name -Unique)
$MissingColumns = @($RequiredColumns | Where-Object { $_ -notin $Columns })
if ($MissingColumns.Count -gt 0) {
    Write-Host "[!] Error: MTX-GROUPS.csv missing required column(s): $($MissingColumns -join ', ')" -ForegroundColor Red
    return
}

foreach ($Group in $Groups) {
    $Name = $Group.DisplayName
    $GroupKind = $Group.GroupType
    $MailNickname = $Group.MailNickname
    $PrimarySMTP = $Group.PrimarySMTP
    $OwnerUPN = $Group.OwnerUPN
    $GroupProtection = Assert-LabNotProtectedObject -InputObject $Group -ObjectType "Group" -ObjectName $Name -AttemptedAction "Create or update group"
    if ($GroupProtection.IsProtected) {
        Write-Host "[$($GroupProtection.State)] $($GroupProtection.Reason)" -ForegroundColor Yellow
        continue
    }

    $OwnerProtection = Assert-LabNotProtectedObject -InputObject ([PSCustomObject]@{ UserPrincipalName = $OwnerUPN }) -ObjectType "GroupOwner" -ObjectName $OwnerUPN -AttemptedAction "Add group owner from explicit MTX row"
    Write-Host "Processing Group: $Name [$GroupKind] [Alias: $MailNickname] [Owner: $OwnerUPN]" -NoNewline
    if ($OwnerProtection.IsProtected) {
        Write-Host " [PROTECTED OWNER: explicit non-destructive owner reference only]" -NoNewline
    }
    
    if ($DryRun) {
        Write-Host " [DRY-RUN: Skip Create Check]" -ForegroundColor Gray
    } else {
        $ExistingGroup = Get-MgGroup -Filter "DisplayName eq '$Name'" -ErrorAction SilentlyContinue
        if ($ExistingGroup) {
            Write-Host " [EXISTS: Skipping]" -ForegroundColor Yellow
        } else {
            Write-Host " [CREATING]" -ForegroundColor Green
            # Logic for real MTX GroupType values: "Security" or "Microsoft365".
            # PrimarySMTP is populated only when MailEnabled is True.
            # New-MgGroup -DisplayName $Name -MailNickname $MailNickname -MailEnabled ([bool]::Parse($Group.MailEnabled)) -SecurityEnabled ([bool]::Parse($Group.SecurityEnabled)) ...
        }
    }
}
