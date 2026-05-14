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

$CSVPath = Join-Path $MTXDir "MTX-USERS.csv"
if (-not (Test-Path $CSVPath)) {
    Write-Host "[!] Error: MTX-USERS.csv not found at $CSVPath" -ForegroundColor Red
    return
}

$Users = Import-Csv $CSVPath
$RequiredColumns = @("UserID", "DisplayName", "FirstName", "LastName", "UserPrincipalName", "MailNickname", "Department", "JobTitle", "UsageLocation", "LicenseSKU", "PasswordProfile", "AccountEnabled")
$Columns = @($Users | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name -Unique)
$MissingColumns = @($RequiredColumns | Where-Object { $_ -notin $Columns })
if ($MissingColumns.Count -gt 0) {
    Write-Host "[!] Error: MTX-USERS.csv missing required column(s): $($MissingColumns -join ', ')" -ForegroundColor Red
    return
}

foreach ($User in $Users) {
    $UserPrincipalName = $User.UserPrincipalName
    $Protection = Assert-LabNotProtectedObject -InputObject $User -ObjectType "User" -ObjectName $UserPrincipalName -AttemptedAction "Create or update user"
    if ($Protection.IsProtected) {
        Write-Host " [$($Protection.State): $($Protection.Reason)]" -ForegroundColor Yellow
        continue
    }

    Write-Host "Processing User: $UserPrincipalName" -NoNewline
    
    # Check if user exists
    if ($DryRun) {
        Write-Host " [DRY-RUN: Skip Create Check]" -ForegroundColor Gray
    } else {
        $ExistingUser = Get-MgUser -UserId $UserPrincipalName -ErrorAction SilentlyContinue
        if ($ExistingUser) {
            Write-Host " [EXISTS: Skipping]" -ForegroundColor Yellow
        } else {
            Write-Host " [CREATING]" -ForegroundColor Green
            $PasswordProfile = @{
                Password = $User.PasswordProfile
                ForceChangePasswordNextSignIn = $true
            }
            if ([string]::IsNullOrWhiteSpace($PasswordProfile.Password)) {
                Write-Host " [BLOCKED: Missing PasswordProfile]" -ForegroundColor Red
                continue
            }
            # New-MgUser -DisplayName $User.DisplayName -UserPrincipalName $UserPrincipalName -MailNickname $User.MailNickname -AccountEnabled ([System.Convert]::ToBoolean($User.AccountEnabled)) -PasswordProfile $PasswordProfile -UsageLocation $User.UsageLocation
        }
    }
}
