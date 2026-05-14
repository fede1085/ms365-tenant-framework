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

$CSVPath = Join-Path $MTXDir "MTX-MAILBOXES.csv"
if (-not (Test-Path $CSVPath)) {
    Write-Host "[!] Error: MTX-MAILBOXES.csv not found" -ForegroundColor Red
    return
}

$Mailboxes = Import-Csv $CSVPath
# Runtime schema alignment: semantic MailboxID remains for traceability, while
# TargetAddress and OwnerUPN are execution identifiers consumed by LAB runtime.
$RequiredColumns = @("MailboxID", "DisplayName", "Alias", "TargetAddress", "Department", "Purpose", "OwnerUPN", "Enabled")
$Columns = @($Mailboxes | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name -Unique)
$MissingColumns = @($RequiredColumns | Where-Object { $_ -notin $Columns })
if ($MissingColumns.Count -gt 0) {
    Write-Host "[!] Error: MTX-MAILBOXES.csv missing required column(s): $($MissingColumns -join ', ')" -ForegroundColor Red
    return
}

foreach ($MBX in $Mailboxes) {
    if ($MBX.Enabled -ne "True") {
        Write-Host "[SKIPPED: Disabled] $($MBX.MailboxID) $($MBX.TargetAddress)" -ForegroundColor Yellow
        continue
    }

    $Address = $MBX.TargetAddress
    $Alias = $MBX.Alias
    $OwnerUPN = $MBX.OwnerUPN
    $MailboxProtection = Assert-LabNotProtectedObject -InputObject $MBX -ObjectType "SharedMailbox" -ObjectName $Address -AttemptedAction "Create or update shared mailbox"
    if ($MailboxProtection.IsProtected) {
        Write-Host "[$($MailboxProtection.State)] $($MailboxProtection.Reason)" -ForegroundColor Yellow
        continue
    }

    $OwnerProtection = Assert-LabNotProtectedObject -InputObject ([PSCustomObject]@{ UserPrincipalName = $OwnerUPN }) -ObjectType "MailboxOwner" -ObjectName $OwnerUPN -AttemptedAction "Reference mailbox owner"
    Write-Host "Processing Shared Mailbox: $Address [Owner: $OwnerUPN]" -NoNewline
    if ($OwnerProtection.IsProtected) {
        Write-Host " [PROTECTED OWNER: no owner mutation allowed]" -NoNewline
    }
    
    if ($DryRun) {
        Write-Host " [DRY-RUN: Skip Create Check]" -ForegroundColor Gray
    } else {
        $ExistingMBX = Get-Mailbox -Identity $Address -ErrorAction SilentlyContinue
        if ($ExistingMBX) {
            Write-Host " [EXISTS: Skipping]" -ForegroundColor Yellow
        } else {
            Write-Host " [CREATING]" -ForegroundColor Green
            # New-Mailbox -Shared -Name $MBX.DisplayName -Alias $Alias -PrimarySmtpAddress $Address
        }
    }
}
