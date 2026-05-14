---
id: "@ARC-OPS-004"
domain: "Collaboration"
layer: "ARC"
type: "Architecture"
status: "Active"
depends_on:
  - "@SYS-ENT-002"
  - "@SYS-MAP-007"
  - "@SYS-STD-003"
  - "@ARC-SYS-000"
  - "@ARC-OPS-001"
  - "@ARC-OPS-002"
  - "@ARC-GOV-002"
  - "@CAN-RUL-001"
  - "@CAN-RUL-002"
  - "@CAN-GRP-002"
authority_level: 1
---

# ARC-OPS-004 — Teams Governance Model

This document extends existing architecture and does not supersede prior ARC governance.

## Purpose

Define Microsoft Teams governance as an operational control model for ownership, lifecycle, guest boundaries, review expectations, and the relationship between Groups, Teams, and SharePoint.

This document governs Teams as collaboration workspaces. It does not redefine the Teams channel strategy already defined in `ARC-OPS-002`.

## Primary Layer

LAYER 2 — Framework Meta-Architecture

## Secondary Layer

LAYER 3 — Tenant Conceptual Modeling

## Ontology Owner

`@ARC`

## Scope

This document covers:

- Teams ownership
- Teams lifecycle
- departmental Teams
- transversal Teams
- guest access boundaries
- archive and review logic
- Group to Team to SharePoint dependency

This document applies to SME-operable governance patterns and future tenant blueprint generation.

## Governed By

- `@SYS-MAP-000` — Framework Ontology & Layer Model
- `@SYS-MAP-004` — Authority Map
- `@SYS-ENT-002` — Workload Entity Extension Map
- `@SYS-MAP-007` — Extension Dependency Map
- `@ARC-SYS-000` — Architecture Control Map
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@CAN-RUL-001` — Authority Inheritance Rules
- `@CAN-RUL-002` — Canonical Naming Enforcement
- `@CAN-GRP-002` — Framework Dependency Engine Model

## Depends On

- `@ARC-OPS-001` — Collaboration Operating Model
- `@ARC-OPS-002` — Teams Channel Strategy
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@SYS-ENT-002` — Workload Entity Extension Map
- `@SYS-MAP-007` — Extension Dependency Map
- `@SYS-STD-003` — Maturity Level Vocabulary

## Feeds

- Future Teams governance blueprint templates
- Future Teams and channels matrix definitions
- Future SharePoint information architecture
- Future access review governance
- Future tenant maturity scoping

## Relationship Chain

```text
Tenant
 -> Department
   -> Group
      -> Team
         -> Channel
         -> SharePointSite
```

Governance inheritance:

```text
Group ownership
 -> Team ownership
 -> Team lifecycle
 -> SharePoint site governance
 -> Access review scope
```

## Governance Principles

- A Team must have a clear operational purpose.
- A Team must map to a Department, transversal workflow, or approved project pattern.
- A Team inherits its primary membership model from its Microsoft 365 Group.
- A Team must have at least one operational owner and one backup owner where feasible.
- Transversal Teams must have explicit business justification and ownership.
- Guest access is controlled by scope, sponsor, and review expectation.
- Teams must be reviewed, archived, or retired when their operational purpose ends.
- Teams governance must remain simple enough for SMB and SME operation.

## Operational Model

### Departmental Teams

Departmental Teams represent stable business functions.

Examples:

```text
Operations
Finance
HR
IT
Support
Sales
```

Departmental Teams should normally align with:

- department ownership
- department group membership
- department SharePoint site
- department document libraries

### Transversal Teams

Transversal Teams support cross-department work.

Examples:

```text
Operations Coordination
Management
All Staff
Client Project
Incident Response
```

Transversal Teams require:

- named owner
- defined participant scope
- review cadence
- clear lifecycle trigger

### Lifecycle

Teams follow this lifecycle:

```text
Propose
 -> Approve
 -> Create
 -> Use
 -> Review
 -> Archive or Retain
 -> Retire when no longer needed
```

No Team should exist permanently without review.

### Guest Boundaries

Guest access is disabled by default unless business collaboration requires it.

Guest-enabled Teams must define:

- sponsor
- allowed purpose
- access duration
- review cadence
- data sensitivity boundary

Guests must not receive access to restricted or privileged collaboration spaces unless future ARCH governance explicitly allows it.

### Archive and Review Logic

A Team should be reviewed when:

- ownership is missing
- usage stops
- the department changes
- the business process ends
- guest access is no longer justified
- sensitive information exposure increases

Archive is preferred before deletion.

## Out of Scope

- Channel naming and channel structure already governed by `ARC-OPS-002`
- PowerShell or Microsoft Graph automation
- BLP templates
- MTX schemas
- AUT runtime contracts
- Purview or DLP configuration
- Enterprise-only Teams lifecycle tooling

## Integration Notes

This document adds governance around Teams as operational workspaces.

It must be interpreted together with:

- `ARC-OPS-001` for collaboration operating model
- `ARC-OPS-002` for channel strategy
- `ARC-GOV-002` for ownership and access governance
- `SYS-ENT-002` for workload entity semantics
- `SYS-MAP-007` for extension dependency chains

Future BLP, MTX, or AUT work must preserve:

```text
ARCH -> BLP -> MTX -> AUT
```
