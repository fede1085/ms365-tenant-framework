param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,

    [Parameter(Mandatory=$true)]
    [string]$TenantId,

    [Parameter(Mandatory=$true)]
    [string]$TenantDomain,

    [string]$EnvironmentName = "PROD",

    [switch]$Execute
)

Write-Host "=== DEPLOY TENANT ==="

function New-RandomTenantPassword {
    param([int]$Length = 20)

    $chars = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@$%*?-_".ToCharArray()
    $bytes = New-Object byte[] ($Length)

    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)

    $pwd = -join ($bytes | ForEach-Object {
        $chars[$_ % $chars.Length]
    })

    return $pwd
}

$Mode = if ($Execute) { "EXECUTE" } else { "DRY-RUN" }

Write-Host "Mode:" $Mode
Write-Host ""

Write-Host "=== TARGET TENANT ==="
Write-Host "Tenant ID      :" $TenantId
Write-Host "Tenant Domain  :" $TenantDomain
Write-Host "Environment    :" $EnvironmentName
Write-Host "Project Path   :" $ProjectPath
Write-Host ""

if ($Execute) {

    $confirmation = Read-Host "Type YES to continue"

    if ($confirmation -ne "YES") {
        throw "❌ Deployment cancelled by user."
    }
}

# -----------------------------
# VALIDATE PATH
# -----------------------------

if (-not (Test-Path $ProjectPath)) {
    throw "❌ ProjectPath not found: $ProjectPath"
}

# -----------------------------
# LOAD FILES
# -----------------------------

$UsersFile       = Join-Path $ProjectPath "MTX-USERS.csv"
$GroupsFile      = Join-Path $ProjectPath "MTX-GROUPS.csv"
$MailboxesFile   = Join-Path $ProjectPath "MTX-MAILBOXES.csv"
$PermissionsFile = Join-Path $ProjectPath "MTX-PERMISSIONS.csv"
$LicensesFile    = Join-Path $ProjectPath "MTX-LICENSES.csv"

$files = @(
    $UsersFile,
    $GroupsFile,
    $MailboxesFile,
    $PermissionsFile,
    $LicensesFile
)

foreach ($f in $files) {

    if (-not (Test-Path $f)) {
        throw "❌ Missing file: $f"
    }
}

$Users       = Import-Csv $UsersFile
$Groups      = Import-Csv $GroupsFile
$Mailboxes   = Import-Csv $MailboxesFile
$Permissions = Import-Csv $PermissionsFile
$Licenses    = Import-Csv $LicensesFile

# -----------------------------
# CONNECT (ONLY EXECUTE)
# -----------------------------

if ($Execute) {

    Write-Host ""
    Write-Host "=== CONNECTING ==="

    Connect-MgGraph `
        -TenantId $TenantId `
        -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"

    Connect-ExchangeOnline `
        -Organization $TenantDomain

    Write-Host ""
    Write-Host "=== VERIFY CONNECTION ==="

    $Context = Get-MgContext

    Write-Host "Connected Tenant ID :" $Context.TenantId
    Write-Host "Expected Tenant ID  :" $TenantId

    if ($Context.TenantId -ne $TenantId) {
        throw "❌ Connected tenant does not match expected tenant."
    }

    Write-Host "[OK] Tenant validation successful."
    Write-Host ""
}

# -----------------------------
# USERS
# -----------------------------

Write-Host "`n--- USERS ---"

foreach ($u in $Users) {

    $userPrincipalName = $u.UserPrincipalName
    $mailNickname = if ($u.MailNickname) {
        $u.MailNickname
    }
    else {
        $userPrincipalName.Split("@")[0]
    }

    $msg = "$userPrincipalName"

    if (-not $Execute) {
        Write-Host "[DRY] Create user $msg"
        continue
    }

    try {

        $ExistingUser = Get-MgUser `
            -Filter "userPrincipalName eq '$userPrincipalName'"

        if ($ExistingUser) {
            Write-Host "[SKIP] User already exists $msg"
            continue
        }

        New-MgUser `
            -DisplayName $u.DisplayName `
            -UserPrincipalName $userPrincipalName `
            -MailNickname $mailNickname `
            -AccountEnabled $true `
            -PasswordProfile @{
                Password = (New-RandomTenantPassword)
                ForceChangePasswordNextSignIn = $true
            }

        Write-Host "[OK] User $msg"
    }
    catch {
        Write-Host "[ERR] User $msg"
        Write-Host $_
    }
}

# -----------------------------
# LICENSES
# -----------------------------

Write-Host "`n--- LICENSES ---"
Write-Host "[INFO] License runtime execution not yet implemented. MTX-LICENSES.csv loaded for future extension."
Write-Host "[INFO] License rows detected:" $Licenses.Count

# -----------------------------
# GROUPS
# -----------------------------

Write-Host "`n--- GROUPS ---"

foreach ($g in $Groups) {

    $msg = "$($g.GroupName)"

    if (-not $Execute) {
        Write-Host "[DRY] Create group $msg"
        continue
    }

    try {

        $ExistingGroup = Get-MgGroup `
            -Filter "displayName eq '$($g.GroupName)'"

        if ($ExistingGroup) {
            Write-Host "[SKIP] Group already exists $msg"
            continue
        }

        New-MgGroup `
            -DisplayName $g.GroupName `
            -MailEnabled $true `
            -MailNickname $g.Alias `
            -SecurityEnabled $false `
            -GroupTypes @("Unified")

        Write-Host "[OK] Group $msg"
    }
    catch {
        Write-Host "[ERR] Group $msg"
        Write-Host $_
    }
}

# -----------------------------
# MAILBOXES
# -----------------------------

Write-Host "`n--- MAILBOXES ---"

foreach ($m in $Mailboxes) {

    $msg = "$($m.Mailbox)"

    if (-not $Execute) {
        Write-Host "[DRY] Create mailbox $msg"
        continue
    }

    try {

        $ExistingMailbox = Get-Mailbox `
            -Identity $m.Mailbox `
            -ErrorAction SilentlyContinue

        if ($ExistingMailbox) {
            Write-Host "[SKIP] Mailbox already exists $msg"
            continue
        }

        New-Mailbox `
            -Shared `
            -Name ($m.Mailbox.Split("@")[0]) `
            -PrimarySmtpAddress $m.Mailbox

        Write-Host "[OK] Mailbox $msg"
        Write-Host "[WAIT] Allowing basic mailbox propagation stabilization for $msg"
        Start-Sleep -Seconds 30
    }
    catch {
        Write-Host "[ERR] Mailbox $msg"
        Write-Host $_
    }
}

# -----------------------------
# PERMISSIONS
# -----------------------------

Write-Host "`n--- PERMISSIONS ---"

foreach ($p in $Permissions) {

    if ($p.Enabled -and $p.Enabled.ToString().ToLowerInvariant() -eq "false") {
        Write-Host "[SKIP] Disabled permission row $($p.PermissionID)"
        continue
    }

    $mbx = $p.TargetAddress
    $trustee = $p.UserUPN
    $accessType = $p.AccessType

    if (-not $Execute) {
        Write-Host "[DRY] $accessType permission for $trustee on $mbx"
        continue
    }

    try {

        if ($accessType -eq "FullAccess") {

            $ExistingPermission = Get-MailboxPermission `
                -Identity $mbx `
                -User $trustee `
                -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.AccessRights -contains "FullAccess" -and
                    -not $_.IsInherited
                }

            if ($ExistingPermission) {
                Write-Host "[SKIP] FullAccess already exists for $trustee on $mbx"
                continue
            }

            Add-MailboxPermission `
                -Identity $mbx `
                -User $trustee `
                -AccessRights FullAccess `
                -Confirm:$false
        }

        elseif ($accessType -eq "SendAs") {

            $ExistingPermission = Get-RecipientPermission `
                -Identity $mbx `
                -Trustee $trustee `
                -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.AccessRights -contains "SendAs"
                }

            if ($ExistingPermission) {
                Write-Host "[SKIP] SendAs already exists for $trustee on $mbx"
                continue
            }

            Add-RecipientPermission `
                -Identity $mbx `
                -Trustee $trustee `
                -AccessRights SendAs `
                -Confirm:$false
        }
        else {
            Write-Host "[WARN] Unsupported permission AccessType $accessType for $trustee on $mbx"
            continue
        }

        Write-Host "[OK] $accessType permission for $trustee on $mbx"
    }
    catch {
        Write-Host "[ERR] $accessType permission for $trustee on $mbx"
        Write-Host $_
    }
}

Write-Host ""
Write-Host "DONE"
