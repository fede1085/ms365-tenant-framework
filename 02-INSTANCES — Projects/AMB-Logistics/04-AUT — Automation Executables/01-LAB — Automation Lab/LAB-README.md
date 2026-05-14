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

- **Source Data**: `..\..\..\03-MTX — Data Matrices\`
- **Execution Rule**: LAB consumes normalized `MTX-*` CSV columns only. BLP and conceptual files are read-only context and are not runtime input.
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
| `LAB-Protected-Objects.ps1` | Tenant-local protected object safety policy. |

## 4. Usage Rules
- **DRY-RUN First**: All scripts support a `-DryRun` switch. Use it first.
- **Tenant Confirmation**: Scripts will display targeting information and wait for a `YES` confirmation.
- **No Automatic Execution**: These scripts are not intended for hands-off automation.
- **No Delete**: No destructive operations are included by design.
- **Validation First**: CSV structure and relationships must validate before tenant-facing execution.
- **No Fake Success**: LAB planning output is not tenant deployment success; live state still requires validation.

## 5. Protected Object Safety

```text
LAB / EXPERIMENTAL / NON-CANONICAL
Semi-controlled execution supported
Not production-grade
No license assignment
Protected-object guarded
```

- LAB runtime protects tenant owner / Global Admin identities from automation mutation.
- `GLOBAL-Admin` is protected by UPN, alias, display name, role, and ObjectId if known.
- Current protected UPN: `homelab@federicomosqueira0910.onmicrosoft.com`.
- Current protected aliases: `global.admin@federicomosqueira.site`, `hello@federicomosqueira.site`.
- Execution is blocked if `LAB-Protected-Objects.ps1` is missing or cannot load.
- Licenses remain skipped; no license assignment is implemented.
- Reset mode must never delete protected objects.
- DryRun is still the first required execution mode.

---
**Experimental Layer — Use with Caution**
