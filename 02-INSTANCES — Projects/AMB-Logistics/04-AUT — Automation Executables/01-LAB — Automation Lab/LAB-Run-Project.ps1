<#
Tenant-local controlled runtime
Production-ready guarded execution
Protected-object enforced
No license assignment
No destructive default behavior
#>

Param(
    [Parameter(Mandatory=$true)]
    [String]$ProjectName,

    [Parameter(Mandatory=$true)]
    [String]$TenantId,

    [Parameter(Mandatory=$true)]
    [String]$TenantDomain,

    [Switch]$Execute,

    [String]$ProtectedGlobalAdminObjectId
)

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
$ProtectedSummary = Get-LabProtectedObjectSummary

$Mode = if ($Execute) { "EXECUTE" } else { "DRY-RUN" }
$ConfirmationPhrase = "I UNDERSTAND THIS WILL MODIFY THE TENANT"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "AMB LOGISTICS - TENANT-LOCAL CONTROLLED RUNTIME" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Project:      $ProjectName"
Write-Host "Mode:         $Mode"
Write-Host "DryRun:       $(-not $Execute)"
Write-Host ""
Write-Host "[PROTECTED OBJECT POLICY]" -ForegroundColor Yellow
Write-Host "Boundary:     $($ProtectedSummary.Boundary)"
Write-Host "UPNs:         $($ProtectedSummary.ProtectedUPNs -join ', ')"
Write-Host "Aliases:      $($ProtectedSummary.ProtectedAliases -join ', ')"
Write-Host "DisplayNames: $($ProtectedSummary.ProtectedDisplayNames -join ', ')"
Write-Host "Roles:        $($ProtectedSummary.ProtectedRoles -join ', ')"
if (-not $ProtectedSummary.ObjectIdResolved) {
    Write-Warning "Protected ObjectId values unresolved; protection continues by UPN, alias, display name, and role."
}
Write-Host ""
Write-Host "[TARGET TENANT]" -ForegroundColor Yellow
Write-Host "TenantId:     $TenantId"
Write-Host "TenantDomain: $TenantDomain"

if ($Execute) {
    $Confirm = Read-Host "Type '$ConfirmationPhrase' to confirm controlled execution"
    if ($Confirm -ne $ConfirmationPhrase) {
        throw "Execution cancelled. Required confirmation phrase was not provided."
    }
}

$ProjectRoot = Resolve-Path (Join-Path $ScriptRoot "..\..\..")
$MTXDir = Get-ChildItem -LiteralPath $ProjectRoot -Directory |
    Where-Object { $_.Name -like "03-MTX*" } |
    Select-Object -First 1 -ExpandProperty FullName

if ([string]::IsNullOrWhiteSpace($MTXDir)) {
    throw "MTX data matrix directory not found under $ProjectRoot"
}

$DeployParams = @{
    MTXDir                       = $MTXDir
    DryRun                       = (-not $Execute)
    TenantId                     = $TenantId
    TenantDomain                 = $TenantDomain
    ProtectedGlobalAdminObjectId = $ProtectedGlobalAdminObjectId
    ConfirmationPhraseAccepted   = $Execute
}

& (Join-Path $ScriptRoot "LAB-Deploy-Tenant.ps1") @DeployParams

Write-Host ""
Write-Host "[ORCHESTRATION COMPLETE]" -ForegroundColor Cyan
