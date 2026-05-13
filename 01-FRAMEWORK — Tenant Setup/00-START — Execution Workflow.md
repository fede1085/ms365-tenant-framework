# Execution Workflow — Tenant Automation Usage

## 1. Purpose

This document defines the safe execution workflow for tenant automation.

It aligns the automation layer with:

```text
ARCH → BLP → MTX → AUT
```

Automation must consume validated Matrix data.

Automation must never redefine architecture, blueprint logic, semantic governance, or tenant design.

---

## 2. Execution State Model

Automation follows this controlled execution model:

```text
READ_ONLY
PLAN
GENERATE
EXECUTE
```

Default state:

```text
READ_ONLY
```

Deployment requires explicit human approval before moving into:

```text
EXECUTE
```

The system must never execute automatically.

---

## 3. Abstraction Layers

The framework uses a strict semantic abstraction model:

- **ARCH:** Architecture doctrine, governance rules, naming standards, and security baselines.
- **BLP:** Reusable operational blueprint templates.
- **MTX:** Real tenant instance data, usually CSV files.
- **AUT:** Automation scripts and deployment logic.

Layer inheritance:

```text
ARCH governs BLP.
BLP informs MTX.
MTX feeds AUT.
AUT does not redefine ARCH or BLP.
```

---

## 4. Framework vs Tenant Instance Boundary

Framework files are authoritative and read-only during tenant execution.

Framework areas:

```text
00-SYSTEM
00-CANONICAL
01-FRAMEWORK
.agents
```

Tenant instance areas:

```text
02-INSTANCES — Projects
```

Tenant projects must not contain framework architecture authority folders.

Do NOT create this inside a tenant project:

```text
01-ARC — Architecture
```

Tenant projects should contain only tenant-scoped operational outputs.

Expected project structure:

```text
/02-INSTANCES — Projects/[project_name]/
    ├── 01-DISCOVERY — Discovery
    ├── 02-BLP — Blueprint Templates
    ├── 03-MTX — Data Matrices
    └── 04-AUT — Automation Executables
```

---

## 5. Safe Generation Flow

The approved tenant-generation flow is:

```text
DISCOVERY
→ PRJ-BLUEPRINT-MASTER-DOC
→ DOMAIN BLP
→ VALIDATION
→ MTX
→ VALIDATION
→ AUT
```

Each phase requires explicit approval before continuing.

Automation must only begin after:

- Blueprint generation is complete
- Blueprint validation is approved
- MTX files are generated
- MTX validation is approved

---

## 6. Matrix Review

Before deployment, review Matrix files inside:

```text
/02-INSTANCES — Projects/[project_name]/03-MTX — Data Matrices/
```

Required files:

```text
MTX-USERS.csv
MTX-GROUPS.csv
MTX-MAILBOXES.csv
MTX-PERMISSIONS.csv
```

Optional files:

```text
MTX-LICENSES.csv
MTX-CHANNELS.csv
MTX-OWNERSHIP.csv
MTX-LIFECYCLE.csv
```

Matrix files are the only valid execution data source for AUT.

AUT must not consume ARCH or BLP files directly as execution data.

---

## 7. Pre-Deployment Safety Gate

Before deployment, confirm:

```text
PROJECT READY — BLP and MTX validated
```

Deployment must remain human-supervised.

The user must explicitly approve deployment.

Do not execute scripts automatically.

Do not simulate deployment.

Do not generate fake execution logs.

---

## 8. Tenant Targeting Requirement

Before live execution, automation must identify the exact target tenant.

Required tenant targeting data:

```text
TenantId
TenantDomain
EnvironmentName
ProjectName
```

Example:

```text
TenantId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
TenantDomain: contoso.onmicrosoft.com
EnvironmentName: DEV
ProjectName: 01-PROJ — Contoso Tenant
```

Automation must display the target tenant before execution.

The user must confirm the target tenant before continuing.

A safe execution prompt should confirm:

```text
Target tenant:
TenantId:
TenantDomain:
Environment:
Project:

Type YES to continue:
```

Execution must stop unless the user explicitly confirms.

---

## 9. Deployment Command

When ready, output only:

```powershell
.\Run-Project.ps1 -ProjectName "[project_name]"
```

Do not run:

```powershell
.\Deploy-Tenant.ps1
```

directly.

`Run-Project.ps1` is the controlled entry point.

`Deploy-Tenant.ps1` is the lower-level execution script.

---

## 10. Required Automation Behavior

Automation must be:

- dry-run first
- validation-driven
- tenant-targeted
- human-confirmed
- idempotent where possible
- Matrix-driven only

Idempotent means:

```text
safe to run more than once without duplicating objects
```

Before creating objects, automation should check whether they already exist.

---

## 11. Password Handling Rule

Automation must not use hardcoded shared passwords.

Do NOT use:

```text
TempP@ss1234
```

Required behavior:

- generate a unique initial password per user, or
- request secure password input, or
- force password reset on first sign-in

Passwords must not be committed to GitHub.

Passwords must not be written into framework files.

---

## 12. Connection Safety

Automation must not rely only on the currently active login context.

Unsafe pattern:

```powershell
Connect-MgGraph
Connect-ExchangeOnline
```

Safer pattern:

```powershell
Connect-MgGraph -TenantId $TenantId
Connect-ExchangeOnline -Organization $TenantDomain
```

Automation must verify the connected tenant before creating users, groups, mailboxes, or permissions.

---

## 13. Automation Flow

Approved flow:

```text
AI generates tenant BLP
→ validation approves BLP
→ AI generates MTX
→ validation approves MTX
→ Run-Project selects project MTX
→ tenant targeting is confirmed
→ Deploy-Tenant executes only after confirmation
```

---

## 14. Notes

- Default mode must be DRY-RUN.
- Confirm before EXECUTE.
- Do NOT run Deploy-Tenant directly.
- Do NOT modify framework files.
- Do NOT generate tenant data inside framework folders.
- All execution data comes from tenant `/03-MTX — Data Matrices/`.
- AUT must never redefine ARCH or BLP.

---

## 15. Final Rule

```text
ARCH = Core governance and architecture doctrine
BLP  = Reusable operational blueprint logic
MTX  = Real tenant instance data
AUT  = Controlled execution scripts
```

Final principle:

```text
Matrix feeds Automation.
Automation does not design the tenant.
Automation only executes validated tenant data.
```