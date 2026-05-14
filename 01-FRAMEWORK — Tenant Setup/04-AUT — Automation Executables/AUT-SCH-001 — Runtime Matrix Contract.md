# AUT-SCH-001 — Runtime Matrix Contract

## Purpose

Define the canonical runtime execution contract for MTX operational data consumed by the Automation layer (AUT).

This document formalizes the distinction between:

- semantic modeling data
- execution runtime data

The goal is to ensure deterministic and execution-safe tenant automation behavior.

---

# Core Principle

```text
Blueprints model business intent.
Runtime MTX models executable operational state.
````

Automation MUST consume runtime-normalized MTX schemas only.

AUT must never infer execution logic directly from Blueprint semantic structures.

---

# Runtime Execution Model

Execution flow:

```text
ARCH
→ BLP
→ Semantic MTX
→ Runtime Normalization
→ Runtime MTX
→ AUT Execution
```

---

# Semantic vs Runtime Distinction

## Semantic MTX

Purpose:

* business modeling
* governance relationships
* conceptual ownership
* organizational abstraction

Examples:

```text
OwnerID
DepartmentCode
ROLE-OPS-LEAD
TEAM-OPS
```

Semantic identifiers are useful for:

* governance
* architecture
* traceability
* ontology consistency

Semantic MTX is NOT execution-safe by itself.

---

## Runtime MTX

Purpose:

* execution
* provisioning
* deployment
* validation
* reconciliation

Runtime MTX must contain execution-resolvable identifiers.

Examples:

```text
OwnerUPN
UserPrincipalName
TargetAddress
PrimarySMTP
MailNickname
```

Runtime MTX is the only valid execution input for AUT.

---

# Runtime Schema Rules

## General Rules

Runtime schemas MUST:

* be execution-resolvable
* avoid ambiguous identifiers
* avoid semantic placeholders
* support deterministic automation
* support validation workflows
* support propagation-aware execution

Runtime schemas SHOULD:

* remain idempotent
* remain human-readable
* remain CSV-compatible
* remain Graph-compatible

---

# Runtime Identity Rules

## Invalid Runtime Fields

Examples:

```text
OwnerID
UserID
TargetID
ROLE-XXX
```

These fields may exist internally for semantic reference only.

AUT execution logic MUST NOT depend exclusively on them.

---

## Valid Runtime Fields

Examples:

```text
UserPrincipalName
OwnerUPN
TargetAddress
PrimarySMTP
MailNickname
```

Execution identifiers must resolve directly inside Microsoft 365 workloads.

---

# Runtime Matrix Contracts

## MTX-USERS.csv

Required runtime fields:

```text
UserPrincipalName
DisplayName
MailNickname
JobTitle
Department
UsageLocation
LicenseSKU
PasswordProfile
AccountEnabled
```

Optional semantic reference fields:

```text
UserID
RoleCode
DepartmentCode
```

---

## MTX-GROUPS.csv

Required runtime fields:

```text
DisplayName
MailNickname
PrimarySMTP
GroupType
OwnerUPN
MailEnabled
SecurityEnabled
```

Optional semantic reference fields:

```text
GroupID
DepartmentCode
```

---

## MTX-MAILBOXES.csv

Required runtime fields:

```text
DisplayName
Alias
TargetAddress
Department
OwnerUPN
```

Optional semantic reference fields:

```text
MailboxID
DepartmentCode
```

---

## MTX-PERMISSIONS.csv

Required runtime fields:

```text
ObjectType
ObjectName
TargetAddress
UserUPN
AccessType
RoleScope
Enabled
```

Optional semantic reference fields:

```text
PermissionID
ObjectID
```

---

# Runtime Normalization Layer

Runtime normalization transforms:

```text
semantic identifiers
→
execution identifiers
```

Examples:

```text
OwnerID
→
OwnerUPN
```

```text
ROLE-OPS-LEAD
→
ops.lead@contoso.com
```

```text
TEAM-OPS
→
ops@contoso.com
```

Normalization may occur:

* during MTX generation
* during MTX validation
* during pre-execution preparation

---

# Execution State Awareness

Runtime MTX must support execution-state-aware automation.

Supported states include:

```text
WAITING_PROPAGATION
VALIDATING_RESULT
WARNING
FAILED
BLOCKED
ROLLBACK_REQUIRED
```

Execution logic must remain:

* propagation-aware
* validation-aware
* human-supervised

---

# Runtime Safety Rules

AUT execution must:

* use runtime-normalized MTX only
* validate schemas before execution
* validate tenant targeting
* support dry-run behavior
* avoid destructive defaults

AUT execution must NOT:

* infer missing runtime identifiers
* execute from semantic placeholders
* bypass validation stages
* redefine Blueprint governance

---

# Relationship to Framework Layers

```text
ARCH
defines governance doctrine

BLP
defines reusable operational structures

Semantic MTX
captures business operational intent

Runtime MTX
captures executable tenant state

AUT
executes runtime-normalized MTX only
```

---

# Final Principle

```text
Semantic MTX explains the tenant.

Runtime MTX executes the tenant.
```

Both layers are valid.

But only Runtime MTX is executable.