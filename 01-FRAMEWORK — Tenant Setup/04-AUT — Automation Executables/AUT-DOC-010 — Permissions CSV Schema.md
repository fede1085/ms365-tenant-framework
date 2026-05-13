# AUT-DOC-010 — MTX-PERMISSIONS.csv Schema

## Reusable Tenant Automation Layer

**Legacy compatibility note:**
- permissions.csv is a legacy reference for MTX-PERMISSIONS.csv

---

# Data Source Rule

Automation reads MTX files.
Automation does not use BLP as execution data.
BLP explains the model.
MTX provides the data.
AUT executes the data.

---

# 1. Purpose

Define the master CSV structure for permissions automation.

This file becomes the source of truth for:

- Shared mailbox access
- Send As rights
- Group memberships
- Owners
- Governance reviews
- Least privilege controls

---

# 2. File Name

```
MTX-PERMISSIONS.csv
```

---

# 3. Core Model

One row = one permission assignment.

Example:

```
Chris gets FullAccess on support@
```

---

# 4. Required Columns

| Column Name | Required | Purpose |
| --- | --- | --- |
| PermissionID | Yes | Unique row ID |
| ObjectType | Yes | Mailbox / Group / Team |
| ObjectName | Yes | Target object |
| TargetAddress | Yes | Mailbox or Group address |
| UserUPN | Yes | User receiving permission |
| AccessType | Yes | Permission type |
| RoleScope | Optional | Context |
| Enabled | Yes | True / False |

---

# 5. Allowed ObjectType Values

```
SharedMailbox
M365Group
Team
SharePointSite
SecurityGroup
```

---

# 6. Allowed AccessType Values

## Exchange

```
FullAccess
SendAs
SendOnBehalf
```

## Membership

```
Member
Owner
```

## SharePoint (future)

```
Read
Edit
FullControl
```

---

# 7. Example Rows

```
PermissionID,ObjectType,ObjectName,TargetAddress,UserUPN,AccessType,RoleScope,Enabled
P001,SharedMailbox,MBX-BIZ-SUP | Support,support@<domain>,ROLE-SUP-AGENT,FullAccess,Support Team,True
P002,SharedMailbox,MBX-BIZ-SUP | Support,support@<domain>,ROLE-SUP-LEAD,SendAs,Support Team,True
P003,SharedMailbox,MBX-SEC-ADM | Admin,admin@<domain>,ROLE-IT-SEC,FullAccess,Admin Team,True
P004,M365Group,GRP-TEAM-OPS | Operations,ops.team@<domain>,ROLE-OPS-LEAD,Member,Operations,True
P005,M365Group,GRP-SEC-ADM | Admin,admin.group@<domain>,ROLE-IT-SEC,Owner,Governance,True
```

---

# 8. Shared Mailbox Standard

## Normal Pattern

Each operational user gets:

```
FullAccess
SendAs
```

Both rows separately.

---

# 9. Governance Rules

## Least Privilege

Only grant needed rights.

## Ownership

Every mailbox/group has owner.

## Separation

Finance rights ≠ HR rights.

## Temporary Access

Use Enabled=False later instead of deleting row.

---

# 10. Validation Rules

Before import:

- target exists
- user exists
- no duplicate identical rows
- valid permission type
- no disabled stale rights without note

---

# 11. PowerShell Consumption Example

## Shared Mailbox

```powershell
Add-MailboxPermission
Add-RecipientPermission
```

## Groups

```powershell
Add-MgGroupMember
Add-MgGroupOwner
```

---

# 12. Review Report Uses

This CSV can answer:

- who can access finance@
- who can send as support@
- orphan groups
- too many admins
- stale permissions

---

# 13. Governance Meaning

This file represents:

```
who can touch what
```

---

# 14. Recommended Future Columns

| Column | Purpose |
| --- | --- |
| StartDate | Temporary access |
| EndDate | Expiry |
| RequestedBy | Audit trail |
| ApprovedBy | Governance trail |
| Notes | Context |

---

# 15. Next Document

```
AUT-DOC-011 — Full Tenant Build Script
```

---

## Related Documents

- AUT-SYS-000 — Automation Control Layer.md
- BLP-SYS-000 — Blueprint Control Layer.md
- ARC-SYS-000 — Architecture Control Map.md
