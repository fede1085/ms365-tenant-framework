# AUT-DOC-012 — Validation & Audit Toolkit

# AUT-DOC-012 — Validation & Audit Toolkit

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

Define the control toolkit used after tenant deployment.

Goal:

Validate that the tenant matches MTX intent.

This document is the operational audit layer.

---

# 2. Audit Philosophy

Build first.  

Validate second.  

Correct drift third.

This toolkit checks:

- users
- groups
- shared mailboxes
- permissions
- naming consistency
- department alignment

---

# 3. Validation Areas

## A. Identity Validation

Check:

- all expected users exist
- usernames are correct
- display names follow standard
- departments are assigned
- technical users keep technical domain
- business users keep public domain

---

## B. Group Validation

Check:

- all required groups exist
- group names match blueprint
- owners exist
- no orphan groups
- members are correct

---

## C. Shared Mailbox Validation

Check:

- all shared mailboxes exist
- display names match
- aliases match
- Full Access is correct
- Send As is correct
- no wrong department members

---

## D. Naming Validation

Check:

- prefixes are correct
- no legacy names remain
- folder structure follows standard
- tags follow taxonomy

---

## E. Governance Validation

Check:

- every department has owner
- every shared mailbox has purpose
- excessive permissions do not exist
- admin boundaries are respected

---

# 4. Minimum Validation Checklist

## Users

- [ ]  homelab exists
- [ ]  admin users exist
- [ ]  department users exist
- [ ]  display names normalized
- [ ]  UPN domains correct

## Groups

- [ ]  GRP-TEAM-OPS | Operations exists
- [ ]  GRP-SEC-ADM | Admin exists

## Shared Mailboxes

- [ ]  admin@
- [ ]  it@
- [ ]  support@
- [ ]  sales@
- [ ]  finance@
- [ ]  hr@
- [ ]  operations@

---

# 5. Audit Inputs

Main inputs:

```
MTX-USERS.csv
MTX-GROUPS.csv
MTX-MAILBOXES.csv
MTX-PERMISSIONS.csv
MTX-LICENSES.csv
```

Optional exports:

```
Get-MgUser export
Get-MgGroup export
Get-Mailbox export
Get-RecipientPermission export
Get-MailboxPermission export
```

---

# 6. Example PowerShell Audit Commands

## Users

```powershell
Get-MgUser -All | Select DisplayName,UserPrincipalName,Department
```

## Groups

```powershell
Get-MgGroup -All | Select DisplayName,MailNickname
```

## Shared Mailboxes

```powershell
Get-Mailbox -RecipientTypeDetails SharedMailbox | Select DisplayName,PrimarySmtpAddress
```

## Send As

```powershell
Get-RecipientPermission support@<domain>
```

## Full Access

```powershell
Get-MailboxPermission support@<domain>
```

---

# 7. Naming Audit Rules

## Display Name

Must follow:

```
PREFIX-FirstName LastName
```

## Shared Mailboxes

Must follow:

```
function@
```

## Group Names

Must follow:

```
Readable Team / Group names
```

Examples:

```
Support Team
Finance Team
Admin Group
```

---

# 8. Drift Detection Examples

## Example 1

Blueprint says:

```
finance@ -> ROLE-FIN-ANALYST + ROLE-FIN-LEAD
```

Reality says:

```
finance@ -> ROLE-FIN-ANALYST + user@<domain>
```

Result:

```
Permission drift
```

---

## Example 2

Blueprint says:

```
ROLE-OPS-LEAD
```

Reality says:

```
Ops Lead
```

Result:

```
Naming drift
```

---

# 9. Output Report Structure

Recommended report sections:

## Section 1 — Summary

```
Users OK: 16/17
Groups OK: 9/9
Mailboxes OK: 7/7
Permissions OK: 28/32
```

## Section 2 — Errors

List all mismatches.

## Section 3 — Warnings

Things not broken but inconsistent.

## Section 4 — Fix Suggestions

Next commands to correct drift.

---

# 10. Audit Frequency

## Lab Mode

After every major script.

## SME Production Style

- monthly light review
- quarterly full audit

---

# 11. Governance Meaning

This toolkit protects:

```
consistency
security
clarity
maintainability
```

---

# 12. Recommended Future Scripts

```
audit-users.ps1
audit-groups.ps1
audit-mailboxes.ps1
audit-permissions.ps1
audit-naming.ps1
```

---

# 13. Final Concept

MTX defines runtime target state.

Audit toolkit verifies reality.

---

# 14. Recommended Next Project Document

```
PRJ-ARC-002 — Full Windows Local Workspace Setup
```

---

## Related Documents

- AUT-SYS-000 — Automation Control Layer.md
- BLP-SYS-000 — Blueprint Control Layer.md
- ARC-SYS-000 — Architecture Control Map.md
