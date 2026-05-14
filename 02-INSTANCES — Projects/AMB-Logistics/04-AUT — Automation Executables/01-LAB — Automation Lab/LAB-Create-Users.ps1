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
                Password = "InitialPassword123!" # In real scenarios, use dynamic generation
                ForceChangePasswordNextSignIn = $true
            }
            # New-MgUser -DisplayName $User.DisplayName -UserPrincipalName $UserPrincipalName -MailNickname $User.MailNickname -AccountEnabled ([System.Convert]::ToBoolean($User.AccountEnabled)) -PasswordProfile $PasswordProfile -UsageLocation $User.UsageLocation
        }
    }
}
