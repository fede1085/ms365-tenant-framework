---
id: "@BLP-OPS-004"
domain: "Collaboration"
layer: "BLP"
type: "Blueprint"
status: "Active"
depends_on:
  - "@BLP-SYS-000"
  - "@ARC-OPS-004"
  - "@ARC-OPS-002"
  - "@ARC-GOV-002"
  - "@SYS-ENT-002"
  - "@SYS-MAP-007"
  - "@SYS-STD-003"
  - "@SYS-STD-004"
  - "@CAN-RUL-001"
  - "@CAN-RUL-002"
  - "@CAN-GRP-002"
authority_level: 3
---

# BLP-OPS-004 — Teams Governance Blueprint

This blueprint operationalizes existing ARC doctrine and does not supersede architectural governance.

## Purpose

Translate Teams governance architecture into reusable blueprint patterns for tenant design, study scenarios, and future matrix generation.

This blueprint defines Teams governance patterns only. It does not redefine channel strategy or create tenant-specific Teams.

## Primary Layer

LAYER 3 — Tenant Conceptual Modeling

## Secondary Layer

LAYER 4 — Tenant Operational Execution Preparation

## Ontology Owner

`@BLP`

## Scope

This blueprint covers:

- departmental Team patterns
- transversal Team patterns
- ownership requirements
- guest access pattern decisions
- review cadence
- archive lifecycle
- Group to Team to SharePoint continuity

It contains template logic only and must not contain real tenant data.

## Governed By

- `@ARC-SYS-000` — Architecture Control Map
- `@BLP-SYS-000` — Blueprint Control Layer
- `@ARC-OPS-004` — Teams Governance Model
- `@ARC-OPS-002` — Teams Channel Strategy
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@SYS-ENT-002` — Workload Entity Extension Map
- `@SYS-MAP-007` — Extension Dependency Map
- `@CAN-RUL-001` — Authority Inheritance Rules
- `@CAN-RUL-002` — Canonical Naming Enforcement
- `@CAN-GRP-002` — Framework Dependency Engine Model

## Depends On

- `@BLP-SYS-000` — Blueprint Control Layer
- `@ARC-OPS-004` — Teams Governance Model
- `@ARC-OPS-002` — Teams Channel Strategy
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@SYS-STD-003` — Maturity Level Vocabulary
- `@SYS-STD-004` — Sector Template Vocabulary

## Feeds

- Future `MTX-TEAMS.csv`
- Future `MTX-CHANNELS.csv`
- Future Teams governance validation
- Future SharePoint sites blueprint patterns
- Future access review blueprint patterns

## Relationship Chain

```text
ARCH Teams Governance
 -> BLP Teams Governance Pattern
 -> Future MTX Team Rows
 -> Future AUT Runtime Contract
```

Object relationship:

```text
Department/Workflow
 -> Group
 -> Team
 -> SharePointSite
 -> AccessReview
```

## Blueprint Objectives

- Ensure every Team has a reusable governance pattern before instance generation.
- Keep Teams aligned to departments, transversal workflows, or approved projects.
- Preserve Group as the membership and access root.
- Define owner and review expectations before MTX generation.
- Prevent uncontrolled Teams sprawl.
- Keep SMB Basic and SME Governance scenarios operable.

## Recommended Patterns

### Departmental Team Pattern

Use for stable departments.

Template fields:

```text
TeamPattern: Departmental
DepartmentCode: <DEPT-CODE>
Purpose: <department collaboration>
PrimaryOwnerRole: <department lead role>
BackupOwnerRole: <backup owner role>
GuestAllowed: No by default
ReviewCadence: Quarterly
ArchiveTrigger: Department inactive or reorganized
```

### Transversal Team Pattern

Use for cross-department coordination.

Template fields:

```text
TeamPattern: Transversal
BusinessProcess: <process name>
ParticipatingDepartments: <department list>
PrimaryOwnerRole: <process owner role>
BackupOwnerRole: <backup owner role>
GuestAllowed: Conditional
ReviewCadence: Quarterly
ArchiveTrigger: Process ended or ownership missing
```

### Project Team Pattern

Use only when a time-bound project requires a dedicated workspace.

Template fields:

```text
TeamPattern: Project
ProjectType: <internal/client/temporary>
PrimaryOwnerRole: <project owner role>
EndDateExpected: <yes/no>
GuestAllowed: Conditional
ReviewCadence: Monthly or Quarterly
ArchiveTrigger: Project closed
```

## Ownership Model

Each Team pattern must define:

- primary owner role
- backup owner role
- owning department or process
- review owner
- guest sponsor when guests are allowed

Owners must be resolvable to real users only at MTX layer.

## Review Model

Recommended review cadence:

| Team Pattern | Review Cadence |
| --- | --- |
| Departmental | Quarterly |
| Transversal | Quarterly |
| Project | Monthly or Quarterly |
| Guest-enabled | Quarterly minimum |
| Sensitive | Monthly or Quarterly based on risk |

Review must validate:

- owner still active
- backup owner still active
- membership still justified
- guest access still required
- Team purpose still valid
- archive trigger not reached

## Naming Guidance

Use existing naming standards from `ARC-STD-007` and `SYS-STD-002`.

Recommended semantic naming patterns:

```text
TEAM-<DEPT-CODE>
TEAM-<PROCESS>
TEAM-<PROJECT-CODE>
```

Actual naming may be adapted by future instance MTX rules but must remain searchable, readable, and consistent.

## Common Mistakes

- Creating a Team without an owner.
- Creating duplicate Teams where channels or existing workflows are enough.
- Treating a Team as independent from its Microsoft 365 Group.
- Allowing guests without sponsor and review cadence.
- Using Teams governance to redefine channel strategy.
- Creating project Teams without archive triggers.

## Out of Scope

- Detailed channel strategy
- Channel naming rules beyond inherited guidance
- Real Team names
- MTX rows
- AUT scripts
- Microsoft Graph execution
- Purview or DLP settings
- Enterprise lifecycle automation

## Integration Notes

This blueprint operationalizes `ARC-OPS-004` and remains subordinate to all ARC governance.

Future MTX generation must resolve roles into real users and must preserve:

```text
Group -> Team -> SharePointSite
```

This blueprint should be paired with `BLP-OPS-005` for SharePoint site patterns and `BLP-GOV-004` for access review patterns.
