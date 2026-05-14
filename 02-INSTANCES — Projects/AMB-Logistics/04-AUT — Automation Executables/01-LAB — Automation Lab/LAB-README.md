# LAB-EXECUTION — AMB Logistics

```text
LAB / EXPERIMENTAL / NON-CANONICAL
Disposable execution layer
Safe to delete
Not authoritative framework governance
```

## 1. Purpose
This directory contains experimental PowerShell scripts for simulating the deployment of the **AMB-Logistics** tenant baseline. These scripts are strictly for lab/experimental use and are decoupled from the authoritative framework logic.

## 2. Logic Model
The scripts follow the execution model:
**MTX (Data) → LAB (Execution) → Tenant (Reality)**

- **Source Data**: `..\..\03-MTX — Data Matrices\`
- **Modules Required**: `Microsoft.Graph`, `ExchangeOnlineManagement`

## 3. Contents
| File | Function |
| :--- | :--- |
| `LAB-Run-Project.ps1` | Main entry point for controlled execution. |
| `LAB-Deploy-Tenant.ps1` | Orchestrator script for full baseline build. |
| `LAB-Create-Users.ps1` | Logic for user creation from AUT-DOC user schema. |
| `LAB-Create-Groups.ps1` | Logic for Security and M365 Groups. |
| `LAB-Create-Mailboxes.ps1` | Logic for Shared Mailboxes in EXO. |
| `LAB-Apply-Permissions.ps1` | Logic for Group/Mailbox permission mapping. |
| `LAB-Validation-Report.ps1` | Post-execution audit and verification. |

## 4. Usage Rules
- **DRY-RUN First**: All scripts support a `-DryRun` switch. Use it first.
- **Tenant Confirmation**: Scripts will display targeting information and wait for a `YES` confirmation.
- **No Automatic Execution**: These scripts are not intended for hands-off automation.
- **No Delete**: No destructive operations are included by design.

---
**Experimental Layer — Use with Caution**
