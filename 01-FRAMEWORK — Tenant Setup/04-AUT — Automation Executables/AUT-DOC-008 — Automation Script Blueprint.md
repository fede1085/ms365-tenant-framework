# AUT-DOC-008 — Automation Script Blueprint

## Reusable Tenant Automation Layer

---

# Data Source Rule

Automation reads MTX files.
Automation does not use BLP as execution data.
BLP explains the model.
MTX provides the data.
AUT executes the data.

---

# 1. Purpose

Define how the full tenant can be deployed automatically.

Goal:

Create a repeatable Microsoft 365 tenant build using PowerShell.

This blueprint becomes the bridge between documents and execution.

---

# 2. Deployment Philosophy

Use:

```
small modular scripts
```

Not:

```
one giant dangerous script
```

---

# 3. Recommended Execution Order

## Phase 01

Create users

## Phase 02

Set display names / departments

## Phase 03

Assign licenses

## Phase 04

Create groups / Teams

## Phase 05

Create shared mailboxes

## Phase 06

Apply memberships

## Phase 07

Apply mailbox permissions
- Mailbox and Teams operations may require propagation wait validation before dependent actions.

## Phase 08

Create aliases

## Phase 09

Optional governance settings

## Phase 10

Validation report

---

# 4. Script Structure

## Main Folder

```
Tenant-Build/
```

## Suggested Files

```
01-connect.ps1
02-create-users.ps1
03-set-user-properties.ps1
04-assign-licenses.ps1
05-create-groups.ps1
06-add-members.ps1
07-create-shared-mailboxes.ps1
08-set-mailbox-permissions.ps1
09-create-aliases.ps1
10-validation-report.ps1
```

---

# 5. Connections Needed

## Microsoft Graph

For:

- users
- licenses
- groups
- Teams-related identity

## Exchange Online

For:

- shared mailboxes
- aliases
- mailbox permissions
- Send As

---

# 6. Example Build Flow

## Connect

```powershell
Connect-MgGraph
Connect-ExchangeOnline
```

## Create User

```powershell
New-MgUser
```

## Create Shared Mailbox

```powershell
New-Mailbox -Shared
```

## Grant Access

```powershell
Add-MailboxPermission
Add-RecipientPermission
```

---

# 7. Data Source Strategy

Use CSV / JSON files as source of truth.

## Recommended Files

```
MTX-USERS.csv
MTX-GROUPS.csv
MTX-MAILBOXES.csv
MTX-PERMISSIONS.csv
MTX-LICENSES.csv
```

---

# 8. Example MTX-USERS.csv

```
DisplayName,UserPrincipalName,Department,Role,License
ROLE-OPS-LEAD,user@<domain>,Operations,Agent,Basic
ROLE-FIN-ANALYST,user@<domain>,Finance,Analyst,Basic
```

---

# 9. Safety Rules

Before any script:

## Dry Run First

Show actions only.

## Logging

Write every change.

## Idempotent Logic

VERIFY
→ SKIP or UPDATE
→ CREATE only if missing

## Rollback Friendly

Keep before/after exports.

## Execution State Awareness

Automation runtime behavior should follow:

- PENDING
- VALIDATING
- READY
- CREATING
- UPDATING
- SKIPPED
- WAITING_PROPAGATION
- VALIDATING_RESULT
- COMPLETED
- WARNING
- FAILED
- BLOCKED
- ROLLBACK_REQUIRED

Execution states are governed by:

## @AUT-SYS-001 — Execution State Model

---

# 10. Governance Add-ons Later

Optional future scripts:

- MFA baseline
- mailbox audits
- unused group cleanup
- naming compliance report
- inactive users report

---

# 11. Gemini / IDE Workflow

Use Gemini to:

- read blueprint docs
- generate CSVs
- generate PowerShell
- validate naming
- compare tenant state vs desired state

Prompt idea:

```
Read all blueprint docs and generate production-safe PowerShell scripts in execution order.
```

---

# 12. Validation Checklist

After deployment verify:

- users created
- groups created
- mailboxes accessible
- Send As works
- names correct
- licenses assigned
- owners present

---

# 13. Final Architecture Logic

Documents define:

```
what should exist
```

Scripts execute:

```
how to create it
```

---

# 14. Next Recommended Documents

```
AUT-DOC-009 — MTX-USERS.csv schema
AUT-DOC-010 — MTX-PERMISSIONS.csv schema
AUT-DOC-011 — Full Tenant Build Script
AUT-DOC-012 — Validation & Audit Toolkit
```

---

# 15. End State

One command should build a realistic SME logistics Microsoft 365 tenant from zero.

---

## Related Documents

- AUT-SYS-000 — Automation Control Layer.md
- BLP-SYS-000 — Blueprint Control Layer.md
- ARC-SYS-000 — Architecture Control Map.md
