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

foreach ($User in $Users) {
    $UPN = $User.UPN
    Write-Host "Processing User: $UPN" -NoNewline
    
    # Check if user exists
    if ($DryRun) {
        Write-Host " [DRY-RUN: Skip Create Check]" -ForegroundColor Gray
    } else {
        $ExistingUser = Get-MgUser -UserId $UPN -ErrorAction SilentlyContinue
        if ($ExistingUser) {
            Write-Host " [EXISTS: Skipping]" -ForegroundColor Yellow
        } else {
            Write-Host " [CREATING]" -ForegroundColor Green
            $PasswordProfile = @{
                Password = "InitialPassword123!" # In real scenarios, use dynamic generation
                ForceChangePasswordNextSignIn = $true
            }
            # New-MgUser -DisplayName $User.DisplayName -UserPrincipalName $UPN -MailNickname $User.FirstName -AccountEnabled $true -PasswordProfile $PasswordProfile -UsageLocation "BE"
        }
    }
}
