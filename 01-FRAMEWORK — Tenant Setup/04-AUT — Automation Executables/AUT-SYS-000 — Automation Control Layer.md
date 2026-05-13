# AUT-SYS-000 — Automation Control Layer

## Reusable Tenant Automation Layer

---

# 1. Purpose of Automation Layer

The Automation layer (AUT) provides the execution engine for the Microsoft 365 tenant deployment. It contains generic, reusable scripts that build the environment based on structural templates and matrix data.

# 2. Layer Relationship

Automation reads MTX files.
Automation does not use BLP as execution data.
BLP explains the model.
MTX provides the data.
AUT executes the data.

**Execution Hierarchy:**
`ARCH (Strategy & Rules) → BLP (Template) → MTX (Data Instance) → AUT (Execution)`

# 3. Required Matrix Input Files

The automation scripts require the following Matrix files for execution:
- `MTX-USERS.csv`
- `MTX-GROUPS.csv`
- `MTX-MAILBOXES.csv`
- `MTX-PERMISSIONS.csv`
- `MTX-LICENSES.csv`

`MTX-LICENSES.csv` is required as an input contract. License runtime execution is not yet implemented.

# 4. Execution Rules

## 4.1 Dry-run first rule
Always execute scripts in a dry-run or what-if mode before committing changes to ensure the script actions match expectations.

## 4.2 Idempotency rule
Scripts must be safe to run multiple times. If an object exists, the script should detect it and either skip it safely or update it cleanly without errors.

## 4.3 No-delete-by-default rule
Scripts must not delete resources automatically. Removals or deletions should require explicit parameters and confirmations.

## 4.4 Protected objects rule
Core administrative accounts and critical systems are protected and must not be altered, removed, or used as regular user accounts in the automation data.

## 4.5 Validation-before-execute rule
Always validate the structure and content of the Matrix CSV inputs before passing them to the execution scripts.

---

## Execution Flow

1. Load Matrix files
2. Validate structure
3. Resolve dependencies (users, groups, mailboxes)
4. Apply changes (create/update only)
5. Validate results
6. Log execution

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
