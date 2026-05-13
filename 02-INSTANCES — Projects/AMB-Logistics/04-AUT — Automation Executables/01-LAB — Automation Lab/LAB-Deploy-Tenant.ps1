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

$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent

Write-Host ">>> Starting Full Tenant Baseline Build..." -ForegroundColor Green

# 1. Connection Logic (Simplified for Lab)
Write-Host ">>> Connecting to Microsoft Graph and Exchange Online..."
if (-not $DryRun) {
    Connect-MgGraph -TenantId $TenantId
    Connect-ExchangeOnline -Organization $TenantDomain -ShowBanner:$false
} else {
    Write-Host "[DRY-RUN] Would connect to Tenant: $TenantId"
}

# 2. Sequential Execution
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
        MTXDir       = $MTXDir
        DryRun       = $DryRun
        TenantId     = $TenantId
        TenantDomain = $TenantDomain
    }
    & "$ScriptDir\$Module" @ModuleParams
}

Write-Host "`n>>> Full Baseline Build Operation Complete." -ForegroundColor Green
