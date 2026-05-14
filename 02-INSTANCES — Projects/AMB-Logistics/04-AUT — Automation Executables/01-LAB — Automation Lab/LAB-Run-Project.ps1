<#
LAB / EXPERIMENTAL / NON-CANONICAL
Disposable execution layer
Safe to delete
Not authoritative framework governance
#>

Param(
    [Parameter(Mandatory=$true)]
    [String]$ProjectName,

    [Switch]$Execute,
    [String]$TenantId,
    [String]$TenantDomain
)

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

$Mode = if ($Execute) { "EXECUTION" } else { "DRY-RUN" }
$Header = @(
    "============================================================"
    "AMB LOGISTICS - LAB EXECUTION ORCHESTRATOR"
    "============================================================"
    "Project: $ProjectName"
    "Mode: $Mode"
) -join [Environment]::NewLine

Write-Host $Header -ForegroundColor Cyan
Write-Host "Protected object policy: $($ProtectedSummary.Boundary)" -ForegroundColor Yellow
Write-Host "Protected UPNs: $($ProtectedSummary.ProtectedUPNs -join ', ')" -ForegroundColor Yellow
Write-Host "Protected DisplayNames: $($ProtectedSummary.ProtectedDisplayNames -join ', ')" -ForegroundColor Yellow

# 1. Target Verification
if ([string]::IsNullOrEmpty($TenantId) -or [string]::IsNullOrEmpty($TenantDomain)) {
    Write-Host "[!] Error: TenantId and TenantDomain must be provided for targeting." -ForegroundColor Red
    return
}

Write-Host ""
Write-Host "[TARGET TENANT]" -ForegroundColor Yellow
Write-Host "TenantId:     $TenantId"
Write-Host "TenantDomain: $TenantDomain"

if ($Execute) {
    $Confirm = Read-Host "Type 'YES' to confirm execution against the target tenant"
    if ($Confirm -ne "YES") {
        Write-Host "Execution cancelled." -ForegroundColor Red
        return
    }

    if (-not (Test-LabProtectedIdentity -UPN "homelab@federicomosqueira0910.onmicrosoft.com" -DisplayName "GLOBAL-Admin" -Role "Global Administrator")) {
        Write-Host "[BLOCKED] GLOBAL-Admin is not listed as protected before write phases." -ForegroundColor Red
        return
    }
}

# 2. Orchestration
$ScriptDir = $ScriptRoot
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$MTXDir = Get-ChildItem -LiteralPath $ProjectRoot -Directory |
    Where-Object { $_.Name -like "03-MTX*" } |
    Select-Object -First 1 -ExpandProperty FullName

if ([string]::IsNullOrEmpty($MTXDir)) {
    Write-Host "[!] Error: MTX data matrix directory not found under $ProjectRoot" -ForegroundColor Red
    return
}

Write-Host ""
Write-Host "[STARTING DEPLOYMENT ORCHESTRATION]" -ForegroundColor Green

$DeployParams = @{
    MTXDir       = $MTXDir
    DryRun       = (-not $Execute)
    TenantId     = $TenantId
    TenantDomain = $TenantDomain
}

& "$ScriptDir\LAB-Deploy-Tenant.ps1" @DeployParams

Write-Host ""
Write-Host "[ORCHESTRATION COMPLETE]" -ForegroundColor Cyan
