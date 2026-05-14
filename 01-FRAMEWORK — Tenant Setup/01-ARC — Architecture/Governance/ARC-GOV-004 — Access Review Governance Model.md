---
id: "@ARC-GOV-004"
domain: "Governance"
layer: "ARC"
type: "Architecture"
status: "Active"
depends_on:
  - "@SYS-ENT-002"
  - "@SYS-MAP-007"
  - "@SYS-STD-003"
  - "@ARC-SYS-000"
  - "@ARC-GOV-001"
  - "@ARC-GOV-002"
  - "@ARC-GOV-016"
  - "@ARC-OPS-004"
  - "@ARC-OPS-005"
  - "@CAN-RUL-001"
  - "@CAN-RUL-002"
  - "@CAN-GRP-001"
  - "@CAN-GRP-002"
authority_level: 2
---

# ARC-GOV-004 — Access Review Governance Model

This document extends existing architecture and does not supersede prior ARC governance.

## Purpose

Define access review governance for validating that access remains required, justified, owned, and aligned with least privilege.

This document establishes review ownership, orphan detection, guest and admin review expectations, cadence, and remediation principles without introducing automation.

## Primary Layer

LAYER 2 — Framework Meta-Architecture

## Secondary Layer

LAYER 3 — Tenant Conceptual Modeling

## Ontology Owner

`@ARC`

## Scope

This document covers access review governance for:

- Groups
- Teams
- Shared Mailboxes
- SharePoint sites and libraries
- Guest users
- Admin role assignments
- privileged or sensitive access

This document defines governance expectations only.

## Governed By

- `@SYS-MAP-000` — Framework Ontology & Layer Model
- `@SYS-MAP-004` — Authority Map
- `@SYS-ENT-002` — Workload Entity Extension Map
- `@SYS-MAP-007` — Extension Dependency Map
- `@ARC-SYS-000` — Architecture Control Map
- `@ARC-GOV-001` — Identity Lifecycle Governance Model
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@ARC-GOV-016` — User Lifecycle Model
- `@CAN-RUL-001` — Authority Inheritance Rules
- `@CAN-RUL-002` — Canonical Naming Enforcement
- `@CAN-GRP-001` — Semantic Dependency Graph
- `@CAN-GRP-002` — Framework Dependency Engine Model

## Depends On

- `@ARC-GOV-001` — Identity Lifecycle Governance Model
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@ARC-GOV-016` — User Lifecycle Model
- `@ARC-OPS-004` — Teams Governance Model
- `@ARC-OPS-005` — SharePoint Information Architecture Model
- `@SYS-ENT-002` — Workload Entity Extension Map
- `@SYS-MAP-007` — Extension Dependency Map
- `@SYS-STD-003` — Maturity Level Vocabulary

## Feeds

- Future access review blueprint templates
- Future governance matrix definitions
- Future validation reports
- Future guest governance design
- Future admin role review design
- Future audit maturity work

## Relationship Chain

```text
Resource
 -> Owner
 -> Reviewer
 -> AccessReview
 -> Decision
 -> Remediation
```

Resource may be:

- Group
- Team
- SharedMailbox
- SharePointSite
- Library
- GuestUser
- AdminRoleAssignment

Lifecycle relationship:

```text
Joiner
 -> Access granted
 -> Periodic review
 -> Mover validation
 -> Leaver removal
```

## Governance Principles

- Access must remain required, justified, owned, and reviewed.
- Every review must have an accountable reviewer.
- Resource owners are responsible for validating membership and delegated access.
- Privileged and sensitive access requires stricter review cadence.
- Orphaned resources are governance failures.
- Guest access requires sponsor validation.
- Reviews should prefer removal of unnecessary access over indefinite exception.
- Review outcomes must be traceable even before automation exists.
- Access reviews must support least privilege and lifecycle governance.

## Operational Model

### Review Ownership

Each review requires:

- resource owner
- reviewer
- review scope
- review cadence
- decision outcome

The reviewer may be the resource owner for standard access, but privileged or sensitive access should involve IT or security validation.

### Orphan Detection

Access review must detect:

- resources without owners
- Teams without active owners
- groups without valid owners
- shared mailboxes without accountable owners
- guest users without sponsors
- admin roles assigned to inactive or inappropriate identities

Orphaned privileged resources are critical governance issues.

### Guest Reviews

Guest access reviews must validate:

- sponsor still exists
- business need remains valid
- scope is still appropriate
- guest access has not expanded beyond approved purpose
- access should continue, reduce, or end

### Admin Reviews

Admin role reviews must validate:

- role is still required
- account is dedicated for administration where required
- privilege level matches job need
- access is not stale
- protected-object rules remain respected

### Review Cadence

Recommended baseline:

| Review Area | Cadence |
| --- | --- |
| Standard Team membership | Quarterly |
| Shared Mailbox access | Quarterly |
| SharePoint sensitive libraries | Quarterly |
| Guest users | Quarterly |
| Security groups | Monthly or quarterly based on sensitivity |
| Admin role assignments | Monthly |
| Orphaned resources | On detection |

Cadence may be adjusted by future maturity level guidance, but must not eliminate review accountability.

### Least Privilege Review Model

Each review asks:

```text
Is access still needed?
Is access correctly scoped?
Is access owned?
Is access justified?
Is access excessive?
Should access be removed or reduced?
```

## Out of Scope

- Access review automation
- Entra entitlement management
- PIM implementation
- PowerShell or Graph scripts
- BLP templates
- MTX schemas
- AUT runtime contracts
- automatic access removal

## Integration Notes

This document extends access governance by defining review behavior across existing and future workload entities.

It must be interpreted together with:

- `ARC-GOV-002` for ownership and approval rules
- `ARC-GOV-016` for lifecycle behavior
- `ARC-OPS-004` for Teams governance
- `ARC-OPS-005` for SharePoint information architecture
- `SYS-ENT-002` for workload entity semantics
- `SYS-MAP-007` for dependency chains

Future implementation must preserve:

```text
ARCH -> BLP -> MTX -> AUT
```

No access review process may redefine ownership, permission, lifecycle, or automation boundaries established by prior ARC and CAN governance.
