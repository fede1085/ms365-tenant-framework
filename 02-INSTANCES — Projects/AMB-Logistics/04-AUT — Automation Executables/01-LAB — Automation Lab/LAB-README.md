# LAB Runtime - AMB Logistics

```text
Tenant-local controlled runtime
Production-ready guarded execution
Protected-object enforced
No license assignment
No destructive default behavior
```

## 1. Purpose

This directory contains the tenant-local controlled runtime for executing the **AMB-Logistics** tenant baseline from normalized MTX data.

Status: **Production-ready for controlled AMB-Logistics tenant execution. Not a generic enterprise automation platform.**

## 2. Logic Model

The scripts follow the execution model:

**MTX (Data) -> LAB Runtime (Guarded Execution) -> Tenant (Reality)**

- **Source Data**: `..\..\..\03-MTX — Data Matrices\`
- **Execution Rule**: LAB consumes normalized `MTX-*` CSV columns only.
- **Modules Required**: `Microsoft.Graph`, `ExchangeOnlineManagement`
- **DryRun First**: DryRun is the default behavior.
- **Execute Gate**: Real execution requires `-Execute` and the phrase `I UNDERSTAND THIS WILL MODIFY THE TENANT`.
- **Optional Workloads**: Teams and SharePoint MTX files may exist for modeling, but this LAB runtime only executes users, groups, shared mailboxes, permissions, validation, and license load/count.

## 3. Contents

| File | Function |
| :--- | :--- |
| `LAB-Run-Project.ps1` | Safe tenant-local entry point. |
| `LAB-Deploy-Tenant.ps1` | Controlled orchestrator for validation, connection, and child script order. |
| `LAB-Create-Users.ps1` | Real create/verify/update-safe user runtime. |
| `LAB-Create-Groups.ps1` | Real create/verify/owners-safe group runtime. |
| `LAB-Create-Mailboxes.ps1` | Real create/verify shared mailbox runtime with bounded propagation polling. |
| `LAB-Apply-Permissions.ps1` | Real apply/verify permissions where supported. |
| `LAB-Validation-Report.ps1` | Static validation by default; live validation only when explicitly requested. |
| `LAB-Protected-Objects.ps1` | Tenant-local protected object safety policy. |

## 4. Execution Rules

- **Tenant-local controlled runtime**
- **Production-ready guarded execution**
- **Protected-object enforced**
- **No license assignment**
- **No destructive default behavior**
- **DryRun first**
- **Execute requires explicit confirmation**

No deletion is implemented by default. No broad tenant wipe is implemented. Reset/rebuild behavior must remain disabled unless separately and explicitly designed with protected-object enforcement.

## 5. Protected Object Safety

Critical protected identities:

| DisplayName | UPN | Alias | Role | ObjectId |
| :--- | :--- | :--- | :--- | :--- |
| `Admin Jan` | `admin.jan@amblogistics.be` | `admin.jan` | `Global Administrator` | `UNKNOWN` |
| `Admin Bram` | `admin.bram@amblogistics.be` | `admin.bram` | `IT Administrator / Teams Administrator` | `UNKNOWN` |
| `Emergency BreakGlass` | `breakglass@amblogistics.be` | `breakglass` | `Emergency Access / Global Administrator` | `UNKNOWN` |

The runtime must never delete, disable, rename, recreate, reset password, change UPN, change aliases, remove roles, remove administrator privileges, remove group memberships, remove ownership, change licenses, convert to a standard user, or include these identities in reset/rebuild logic.

ObjectId handling:

- ObjectId values are unknown until supplied or resolved during live execution.
- `-ProtectedGlobalAdminObjectId "<object-id>"` remains available as a compatibility parameter for adding a known protected ObjectId at runtime.
- In live execution, the orchestrator attempts read-only `Get-MgUser` lookups for the protected AMB UPNs after Graph connection and before write phases.
- If unresolved, execution may continue only with UPN, alias, display name, and role protection validated, and logs a warning.

## 6. Commands

DryRun:

```powershell
.\LAB-Run-Project.ps1 -ProjectName "AMB-Logistics" -TenantId "<tenant-id>" -TenantDomain "<tenant-domain>"
```

Execute:

```powershell
.\LAB-Run-Project.ps1 -ProjectName "AMB-Logistics" -TenantId "<tenant-id>" -TenantDomain "<tenant-domain>" -Execute -ProtectedGlobalAdminObjectId "<object-id>"
```

Static validation:

```powershell
.\LAB-Validation-Report.ps1 -MTXDir "..\..\..\03-MTX — Data Matrices" -TenantId "<tenant-id>" -TenantDomain "<tenant-domain>"
```

Live validation:

```powershell
.\LAB-Validation-Report.ps1 -MTXDir "..\..\..\03-MTX — Data Matrices" -TenantId "<tenant-id>" -TenantDomain "<tenant-domain>" -LiveValidation
```

## 7. Final Runtime Behavior

- Users: real create/verify/update-safe
- Groups: real create/verify/owners-safe
- Shared mailboxes: real create/verify with bounded propagation polling
- Permissions: real apply/verify where supported; protected principals are skipped
- Licenses: skipped
- Teams/SharePoint: modeled in optional MTX only; not executed by this LAB runtime
- Delete/reset: disabled by default
- AMB admin and break-glass identities: protected
