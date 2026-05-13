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

$Header = @"
============================================================
AMB LOGISTICS - LAB EXECUTION ORCHESTRATOR
============================================================
Project: $ProjectName
Mode: $(if ($Execute) { "EXECUTION" } else { "DRY-RUN" })
"@

Write-Host $Header -ForegroundColor Cyan

# 1. Target Verification
if ([string]::IsNullOrEmpty($TenantId) -or [string]::IsNullOrEmpty($TenantDomain)) {
    Write-Host "[!] Error: TenantId and TenantDomain must be provided for targeting." -ForegroundColor Red
    return
}

Write-Host "`n[TARGET TENANT]" -ForegroundColor Yellow
Write-Host "TenantId:     $TenantId"
Write-Host "TenantDomain: $TenantDomain"

if ($Execute) {
    $Confirm = Read-Host "`nType 'YES' to confirm execution against the target tenant"
    if ($Confirm -ne "YES") {
        Write-Host "Execution cancelled." -ForegroundColor Red
        return
    }
}

# 2. Orchestration
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$MTXDir = Join-Path $ScriptDir "..\..\03-MTX — Data Matrices"

Write-Host "`n[STARTING DEPLOYMENT ORCHESTRATION]" -ForegroundColor Green

$DeployParams = @{
    MTXDir       = $MTXDir
    DryRun       = (-not $Execute)
    TenantId     = $TenantId
    TenantDomain = $TenantDomain
}

& "$ScriptDir\LAB-Deploy-Tenant.ps1" @DeployParams

Write-Host "`n[ORCHESTRATION COMPLETE]" -ForegroundColor Cyan
