# AUT-OPS-002 — Runtime Normalization Pipeline

## Purpose

Define the operational pipeline that transforms Semantic MTX into Runtime MTX for deterministic Microsoft 365 automation execution.

This document formalizes:

```text
semantic operational intent
→
runtime executable state
````

The goal is to ensure:

* deterministic execution
* runtime-safe provisioning
* propagation-aware automation
* schema consistency
* validation-driven deployment

---

# Core Principle

```text
Blueprints describe the business.

Semantic MTX models operational intent.

Runtime MTX models executable tenant state.

AUT executes Runtime MTX only.
```

---

# Pipeline Overview

Runtime normalization pipeline:

```text
ARCH
→ BLP
→ Semantic MTX
→ Runtime Enrichment
→ Runtime Mapping
→ Runtime Validation
→ Runtime MTX
→ AUT Execution
```

---

# Pipeline Stages

## Stage 1 — Semantic MTX Intake

Purpose:

Load tenant operational intent generated from Blueprint logic.

Semantic MTX may contain:

* semantic identifiers
* governance references
* conceptual ownership
* organizational abstractions

Examples:

```text
OwnerID
DepartmentCode
ROLE-OPS-LEAD
TEAM-OPS
```

Semantic MTX is authoritative for:

* business meaning
* governance relationships
* architecture traceability

Semantic MTX is NOT execution-safe.

---

## Stage 2 — Runtime Enrichment

Purpose:

Generate runtime execution properties required by Microsoft 365 workloads.

Examples:

```text
MailNickname generation
PrimarySMTP generation
UsageLocation assignment
LicenseSKU expansion
TargetAddress normalization
```

Enrichment may derive values from:

* tenant domain
* department logic
* governance rules
* execution defaults

Examples:

```text
ops.lead
→
ops.lead@contoso.com
```

```text
TEAM-OPS
→
ops@contoso.com
```

---

# Runtime Enrichment Rules

## MailNickname

Must:

* be unique
* avoid spaces
* remain Exchange-compatible

Examples:

```text
Operations Team
→
operations.team
```

---

## PrimarySMTP

Must:

* use valid tenant domain
* support Exchange resolution
* remain execution-resolvable

Examples:

```text
operations@contoso.com
```

---

## UsageLocation

Must:

* use ISO country codes
* support Microsoft licensing requirements

Examples:

```text
BE
NL
UK
US
```

---

## LicenseSKU

Must:

* resolve to valid Microsoft license SKU
* remain runtime-deployable

Examples:

```text
BUSINESS_PREMIUM
BUSINESS_STANDARD
F3
```

---

# Stage 3 — Runtime Mapping

Purpose:

Transform semantic identifiers into execution identifiers.

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

---

# Mapping Rules

## Semantic Identifiers

Semantic identifiers may exist for:

* governance
* ontology
* traceability
* architecture references

Examples:

```text
UserID
OwnerID
GroupID
MailboxID
DepartmentCode
```

Semantic identifiers are NOT authoritative for execution.

---

## Runtime Identifiers

Runtime identifiers must resolve directly inside Microsoft 365 services.

Examples:

```text
UserPrincipalName
OwnerUPN
PrimarySMTP
TargetAddress
MailNickname
```

AUT execution logic must use runtime identifiers only.

---

# Stage 4 — Runtime Validation

Purpose:

Validate Runtime MTX before execution.

Validation must occur BEFORE:

* provisioning
* permission assignment
* mailbox operations
* license assignment
* Teams provisioning

---

# Required Validation Checks

## Schema Validation

Validate:

* required columns
* column naming
* CSV structure
* encoding consistency

---

## Identity Resolution Validation

Validate:

* valid UPN formatting
* unique SMTP addresses
* resolvable owner assignments
* duplicate prevention

---

## Relationship Validation

Validate:

* mailbox ownership
* permission targets
* group ownership
* department consistency

---

## Security Validation

Validate:

* admin account separation
* privileged role restrictions
* protected account handling
* invalid SendAs assignments

---

## Runtime State Validation

Validate:

* propagation readiness
* execution dependencies
* blocked objects
* retry eligibility

---

# Stage 5 — Runtime MTX Output

Purpose:

Generate execution-safe Runtime MTX.

Runtime MTX becomes the authoritative execution input for AUT.

Runtime MTX must:

* remain deterministic
* remain execution-safe
* remain propagation-aware
* remain validation-compliant

---

# Runtime MTX Contracts

Runtime MTX must comply with:

```text
AUT-SCH-001 — Runtime Matrix Contract
```

Runtime MTX schemas include:

* MTX-USERS.csv
* MTX-GROUPS.csv
* MTX-MAILBOXES.csv
* MTX-PERMISSIONS.csv
* MTX-LICENSES.csv

---

# Execution State Awareness

Runtime normalization must support execution-aware automation states.

Supported states include:

```text
WAITING_PROPAGATION
VALIDATING_RESULT
WARNING
FAILED
BLOCKED
ROLLBACK_REQUIRED
```

Execution must remain:

* validation-driven
* human-supervised
* propagation-aware

---

# Propagation Awareness

Microsoft 365 workloads may propagate asynchronously.

Examples:

* user creation
* mailbox provisioning
* group replication
* Teams enablement
* license assignment

Runtime normalization must prepare execution logic for propagation-aware validation.

Execution logic should support:

* bounded retries
* delayed validation
* dependency sequencing
* non-destructive retry behavior

---

# Runtime Safety Rules

AUT execution must:

* consume Runtime MTX only
* validate schemas before execution
* validate tenant targeting
* support dry-run mode
* support idempotent behavior

AUT execution must NOT:

* infer missing runtime identifiers
* execute from semantic placeholders
* bypass validation
* redefine governance doctrine

---

# Relationship to Framework Layers

```text
ARCH
defines governance doctrine

BLP
defines reusable operational structure

Semantic MTX
captures tenant operational intent

Runtime Normalization
transforms intent into executable state

Runtime MTX
captures execution-safe tenant state

AUT
executes Runtime MTX
```

---

# Final Principle

```text
Semantic MTX explains the tenant.

Runtime MTX executes the tenant.

Runtime Normalization connects both layers.
```