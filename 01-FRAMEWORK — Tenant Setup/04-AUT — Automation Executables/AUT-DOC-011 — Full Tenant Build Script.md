# AUT-DOC-011 — Full Tenant Build Script

## Reusable Tenant Automation Layer

**Legacy compatible naming:**
- users.csv → MTX-USERS.csv
- groups.csv → MTX-GROUPS.csv
- mailboxes.csv → MTX-MAILBOXES.csv
- permissions.csv → MTX-PERMISSIONS.csv
- licenses.csv → MTX-LICENSES.csv

Legacy names are references only. Active runtime input names use the MTX-* filenames below.

Preferred MTX naming:

- MTX-USERS.csv
- MTX-GROUPS.csv
- MTX-MAILBOXES.csv
- MTX-PERMISSIONS.csv
- MTX-LICENSES.csv

---

# Data Source Rule

Automation reads MTX files.
Automation does not use BLP as execution data.
BLP explains the model.
MTX provides the data.
AUT executes the data.

---

# 1. Purpose

Provide the master execution script model.

Goal:

Build a full Microsoft 365 SME logistics tenant from zero using blueprint CSV files.

This is the orchestration layer.

---

# 2. Required Input Files

```
MTX-USERS.csv
MTX-GROUPS.csv
MTX-MAILBOXES.csv
MTX-PERMISSIONS.csv
MTX-LICENSES.csv
```

License runtime execution status:

```text
License runtime execution not yet implemented.
```

Current scripts load `MTX-LICENSES.csv` to prevent input ambiguity, but do not assign licenses yet.

Optional:

```
folders.csv
aliases.csv
```

---

# 3. Required Connections

## Microsoft Graph

For:

- users
- groups
- licenses

## Exchange Online

For:

- shared mailboxes
- mailbox permissions
- aliases

---

# 4. Recommended File Name

```
build-tenant.ps1
```

---

# 5. Master Flow

```
01 Connect
02 Validate CSVs
03 Create Users
04 Set User Properties
05 Assign Licenses
06 Create Groups
07 Add Members
08 Create Shared Mailboxes
09 Apply Permissions
10 Add Aliases
11 Validation Report
```

---

# 6. Script Skeleton

```powershell
# =====================================
# BUILD TENANT
# =====================================

# Connect

# Connection Strategy
# Sandbox / Lab environments may use active-session authentication.
# Production environments should prefer explicit tenant targeting.

# Example production-safe pattern:
# Connect-MgGraph -TenantId $TenantId
# Connect-ExchangeOnline -Organization $TenantDomain

# Current runtime connection
Connect-MgGraph
Connect-ExchangeOnline
Write-Host "Starting Tenant Build..."

# Import Data
$Users       = Import-Csv .\MTX-USERS.csv
$Licenses    = Import-Csv .\MTX-LICENSES.csv
$Permissions = Import-Csv .\MTX-PERMISSIONS.csv

# License runtime execution not yet implemented.

# Step 1 Users
foreach ($u in $Users) {
    Write-Host "Create user: $($u.UserPrincipalName)"
}

# Step 2 Permissions
foreach ($p in $Permissions) {
    Write-Host "Apply permission: $($p.AccessType)"
}

Write-Host "Completed."
```

---

# 7. Real Modular Version

## Main Script Calls Child Scripts

```powershell
.\01-connect.ps1
.\02-create-users.ps1
.\03-groups.ps1
.\04-mailboxes.ps1
.\05-permissions.ps1
.\06-report.ps1
```

Better than one huge file.

---

# 8. Safety Features

## Dry Run Switch

```powershell
-param DryRun
```

If DryRun:

- no changes
- show actions only

---

## Logging

```powershell
Start-Transcript
```

Save all output.

---

## Exists Check

Before create:

```
if exists -> skip
```

---

# 9. Example Real Actions

## Create User

```powershell
New-MgUser
```

## Create Group

```powershell
New-MgGroup
```

## Create Shared Mailbox

```powershell
New-Mailbox -Shared
```

## Full Access

```powershell
Add-MailboxPermission
```

## Send As

```powershell
Add-RecipientPermission
```

---

# 10. Folder Creation Note

Mailbox folders often require:

- Outlook automation
- Graph mailbox APIs
- EWS legacy methods

Recommended phase 2.

---

# 11. Validation Report Output

After build generate:

```
Users Created: 17
Groups Created: 9
Mailboxes Created: 7
Permissions Applied: 34
Errors: 0
```

---

# 12. Governance Checks

After build verify:

- every department exists
- every mailbox has owner
- every user has department
- no duplicate aliases
- no missing permissions

---

# 13. End Goal

One command:

```powershell
.\build-tenant.ps1
```

Builds tenant baseline.

---

# 14. Future Versions

## v2

- Teams channels
- SharePoint libraries
- Planner plans

## v3

- MFA baseline
- Conditional Access
- Intune devices

---

# 15. Next Document

```
AUT-DOC-012 — Validation & Audit Toolkit
```

---

## Related Documents

- AUT-SYS-000 — Automation Control Layer.md
- BLP-SYS-000 — Blueprint Control Layer.md
- ARC-SYS-000 — Architecture Control Map.md

## Execution Path Expectations
- Scripts assume framework-relative paths as documented in `scripts/Run-Project.ps1`.
- Preferred execution directory is `01-FRAMEWORK — Tenant Setup/04-AUT — Automation Executables/scripts`.
- `-ProjectPath` can be provided explicitly to avoid path-resolution ambiguity.
- Path conventions are ontology-dependent and must not be renamed in hardening passes.
