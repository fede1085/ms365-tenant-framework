# AUT-DOC-009 — MTX-USERS.csv Schema

## Reusable Tenant Automation Layer

**Legacy compatibility note:**
- users.csv is a legacy reference for MTX-USERS.csv

---

# Data Source Rule

Automation reads MTX files.
Automation does not use BLP as execution data.
BLP explains the model.
MTX provides the data.
AUT executes the data.

---

# 1. Purpose

Define the master CSV structure for automated user creation.

This file becomes the source of truth for:

- New users
- Display names
- Login IDs
- Departments
- Roles
- Licenses
- Password generation
- Governance consistency

---

# 2. File Name

```
MTX-USERS.csv
```

---

# 3. Required Columns

| Column Name | Required | Purpose |
| --- | --- | --- |
| UserID | Optional | Legacy/internal reference ID. Not required by current AUT runtime scripts. |
| DisplayName | Yes | Visible Microsoft name |
| FirstName | Yes | Given name |
| LastName | Yes | Surname |
| UserPrincipalName | Yes | Login email |
| MailNickname | Yes | Alias |
| Department | Yes | Department name |
| JobTitle | Yes | Role title |
| UsageLocation | Yes | Country code |
| LicenseSKU | Optional | License to assign |
| PasswordProfile | Optional | Initial password |
| AccountEnabled | Yes | True / False |

---

# 4. Recommended Extra Columns

| Column Name | Purpose |
| --- | --- |
| ManagerUPN | Reporting line |
| OfficeLocation | Physical office |
| EmployeeType | Permanent / Temp / Contractor |
| CostCenter | Finance mapping |
| MobilePhone | Optional |
| City | Reporting |
| Country | Reporting |

---

# 5. Example Rows

```
DisplayName,FirstName,LastName,UserPrincipalName,MailNickname,Department,JobTitle,UsageLocation,LicenseSKU,PasswordProfile,AccountEnabled
U001,ROLE-GLOBAL-ADMIN,Global,Admin,admin@<tenant-domain>,admin,Executive,Global Administrator,BE,BUSINESS_BASIC,<GENERATED_SECURE_PASSWORD>,True
U002,ROLE-IT-ADMIN,IT,Admin,it.admin@<tenant-domain>,it.admin,Admin,License Administrator,BE,,<GENERATED_SECURE_PASSWORD>,True
U003,ROLE-FIN-ANALYST,Finance,Analyst,user@<domain>,user.finance,Finance,Finance Analyst,BE,BUSINESS_BASIC,<GENERATED_SECURE_PASSWORD>,True
```

---

Lab-only placeholder example:

<GENERATED_SECURE_PASSWORD>

Production deployments should:

- generate unique random passwords
- force password reset on first sign-in
- require MFA
- avoid shared or hardcoded passwords

---

# 6. Naming Rules

## DisplayName

```
PREFIX-FirstName LastName
```

## UserPrincipalName

## Functional Users

```
firstname.department@domain
```

## Technical Users

```
name.function@domain
```

---

# 7. Department Allowed Values

```
Executive
Admin
Operations
Support
Sales
Finance
HR
IT
Security
Development
```

---

# 8. JobTitle Examples

```
Global Administrator
License Administrator
User Administrator
Finance Analyst
Support Agent
Sales Representative
Operations Coordinator
Developer
Security Administrator
```

---

# 9. LicenseSKU Examples

Use tenant real SKU names later.

```
BUSINESS_BASIC
BUSINESS_STANDARD
NONE
```

---

# 10. Password Strategy

Lab-only placeholder example:

<GENERATED_SECURE_PASSWORD>

Production deployments should:

- generate unique random passwords
- force password reset on first sign-in
- require MFA
- avoid shared or hardcoded passwords

---

# 11. Validation Rules

Before import:

- no duplicate UPN
- no empty DisplayName
- valid domain
- valid department
- valid country code
- no spaces in nickname

---

# 12. PowerShell Consumption Example

```powershell
$users = Import-Csv .\MTX-USERS.csv
foreach ($u in $users) {
    # create user logic
}
```

---

# 13. Governance Logic

This file should be maintained manually and versioned.

It represents:

```
who exists in the company
```

---

# 14. Next Document

```
AUT-DOC-010 — MTX-PERMISSIONS.csv Schema
```

---

## Related Documents

- AUT-SYS-000 — Automation Control Layer.md
- BLP-SYS-000 — Blueprint Control Layer.md
- ARC-SYS-000 — Architecture Control Map.md
