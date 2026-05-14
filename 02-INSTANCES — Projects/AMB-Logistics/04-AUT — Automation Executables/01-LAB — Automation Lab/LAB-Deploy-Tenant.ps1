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

Write-Host ">>> Starting Full Tenant Baseline Build..." -ForegroundColor Green
Write-Host ">>> Protected object policy loaded: $($ProtectedSummary.Boundary)" -ForegroundColor Yellow
Write-Host ">>> Protected UPNs: $($ProtectedSummary.ProtectedUPNs -join ', ')" -ForegroundColor Yellow
Write-Host ">>> Protected DisplayNames: $($ProtectedSummary.ProtectedDisplayNames -join ', ')" -ForegroundColor Yellow

if (-not $DryRun) {
    if ([string]::IsNullOrEmpty($TenantId) -or [string]::IsNullOrEmpty($TenantDomain)) {
        Write-Host "[BLOCKED] TenantId and TenantDomain are required before non-dry-run execution." -ForegroundColor Red
        return
    }

    Write-Host "[TARGET TENANT]" -ForegroundColor Yellow
    Write-Host "TenantId:     $TenantId"
    Write-Host "TenantDomain: $TenantDomain"
    $Confirm = Read-Host "Type 'YES' to confirm LAB execution against the target tenant"
    if ($Confirm -ne "YES") {
        Write-Host "Execution cancelled." -ForegroundColor Red
        return
    }

    if (-not (Test-LabProtectedIdentity -UPN "homelab@federicomosqueira0910.onmicrosoft.com" -DisplayName "GLOBAL-Admin" -Role "Global Administrator")) {
        Write-Host "[BLOCKED] GLOBAL-Admin is not listed as protected before write phases." -ForegroundColor Red
        return
    }
}

# Validate MTX schema and relationships before any tenant-facing connection.
$ValidationParams = @{
    MTXDir       = $MTXDir
    DryRun       = $true
    TenantId     = $TenantId
    TenantDomain = $TenantDomain
}
& "$ScriptDir\LAB-Validation-Report.ps1" @ValidationParams

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
