param(
    [string]$ProjectName,
    [string]$ProjectPath,

    [string]$TenantId,
    [string]$TenantDomain,

    [string]$EnvironmentName = "PROD",

    [switch]$Execute
)

$BasePath = "..\..\..\02-INSTANCES — Projects"

# -----------------------------
# ORCHESTRATION MODE
# -----------------------------

$OrchestrationMode = if ($Execute) {
    "EXECUTE"
}
else {
    "READ_ONLY / DRY-RUN"
}

# -----------------------------
# EXECUTION PATH NOTES
# -----------------------------
# Expected working directory:
# 01-FRAMEWORK — Tenant Setup/04-AUT — Automation Executables/scripts
#
# Base path resolution depends on framework-relative structure.
#
# You may pass:
# -ProjectPath
# -TenantId
# -TenantDomain
#
# explicitly to bypass interactive prompts.

Write-Host "=== PROJECT DEPLOY RUNNER ==="
Write-Host ""
Write-Host "Orchestration Mode:" $OrchestrationMode
Write-Host "Working directory:" (Get-Location)

Write-Host "Expected base path root:" `
    (Resolve-Path "..\..\.." -ErrorAction SilentlyContinue)

Write-Host ""

# -----------------------------
# 1. RESOLVE PROJECT
# -----------------------------

if ($ProjectPath) {

    $projectFullPath = Resolve-Path $ProjectPath
}
elseif ($ProjectName) {

    $projectFullPath = Join-Path $BasePath $ProjectName
}
else {

    Write-Host ""
    Write-Host "Available Projects:"

    $projects = Get-ChildItem $BasePath -Directory

    for ($i=0; $i -lt $projects.Count; $i++) {

        Write-Host "[$i] $($projects[$i].Name)"
    }

    $selection = Read-Host "Select project number"

    $projectFullPath = $projects[$selection].FullName
}

# -----------------------------
# 2. VALIDATE
# -----------------------------

$mtxPath = Join-Path `
    $projectFullPath `
    "03-MTX — Data Matrices"

if (-not (Test-Path $mtxPath)) {

    throw "❌ Matrix folder not found: $mtxPath"
}

$requiredFiles = @(
    "MTX-USERS.csv",
    "MTX-GROUPS.csv",
    "MTX-MAILBOXES.csv",
    "MTX-PERMISSIONS.csv",
    "MTX-LICENSES.csv"
)

foreach ($file in $requiredFiles) {

    if (-not (Test-Path (Join-Path $mtxPath $file))) {

        throw "❌ Missing file: $file"
    }
}

Write-Host ""
Write-Host "=== PROJECT VALIDATION ==="
Write-Host ""

Write-Host "Project Path :" $projectFullPath
Write-Host "Matrix Path  :" $mtxPath
Write-Host ""

# -----------------------------
# 3. TENANT TARGETING
# -----------------------------

if (-not $TenantId) {

    $TenantId = Read-Host "Tenant ID"
}

if (-not $TenantDomain) {

    $TenantDomain = Read-Host "Tenant Domain"
}

Write-Host ""
Write-Host "=== TARGET TENANT ==="

Write-Host "Tenant ID      :" $TenantId
Write-Host "Tenant Domain  :" $TenantDomain
Write-Host "Environment    :" $EnvironmentName

Write-Host ""

# -----------------------------
# 4. EXECUTION CONFIRMATION
# -----------------------------

if (-not $Execute) {

    Write-Host "[READ_ONLY / DRY-RUN MODE]"

    .\Deploy-Tenant.ps1 `
        -ProjectPath $mtxPath `
        -TenantId $TenantId `
        -TenantDomain $TenantDomain `
        -EnvironmentName $EnvironmentName

    $confirm = Read-Host `
        "Type YES to continue into EXECUTE mode"

    if ($confirm -ne "YES") {

        Write-Host "Cancelled."

        exit
    }

    $Execute = $true
}

# -----------------------------
# 5. EXECUTE DEPLOY
# -----------------------------

Write-Host ""
Write-Host "=== STARTING DEPLOYMENT ==="
Write-Host ""

.\Deploy-Tenant.ps1 `
    -ProjectPath $mtxPath `
    -TenantId $TenantId `
    -TenantDomain $TenantDomain `
    -EnvironmentName $EnvironmentName `
    -Execute

Write-Host ""
Write-Host "DONE"
