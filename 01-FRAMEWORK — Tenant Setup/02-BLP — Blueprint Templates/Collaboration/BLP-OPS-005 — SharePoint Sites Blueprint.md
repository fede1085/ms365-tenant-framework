---
id: "@BLP-OPS-005"
domain: "Collaboration"
layer: "BLP"
type: "Blueprint"
status: "Active"
depends_on:
  - "@BLP-SYS-000"
  - "@ARC-OPS-005"
  - "@ARC-OPS-004"
  - "@ARC-GOV-002"
  - "@ARC-COMP-002"
  - "@SYS-ENT-002"
  - "@SYS-MAP-007"
  - "@SYS-STD-003"
  - "@SYS-STD-004"
  - "@CAN-RUL-001"
  - "@CAN-RUL-002"
  - "@CAN-GRP-002"
authority_level: 3
---

# BLP-OPS-005 — SharePoint Sites Blueprint

This blueprint operationalizes existing ARC doctrine and does not supersede architectural governance.

## Purpose

Translate SharePoint information architecture doctrine into reusable blueprint patterns for sites, libraries, ownership, inheritance, document segmentation, and basic sensitivity awareness.

This blueprint defines structure patterns only. It does not create tenant-specific SharePoint sites or configure Purview, DLP, or retention policies.

## Primary Layer

LAYER 3 — Tenant Conceptual Modeling

## Secondary Layer

LAYER 4 — Tenant Operational Execution Preparation

## Ontology Owner

`@BLP`

## Scope

This blueprint covers:

- Team-backed SharePoint site patterns
- Site to Library patterns
- SME document structure
- ownership model
- permission inheritance
- minimal library strategy
- document segmentation
- conceptual sensitivity levels

It contains reusable patterns only and must not contain real tenant data.

## Governed By

- `@ARC-SYS-000` — Architecture Control Map
- `@BLP-SYS-000` — Blueprint Control Layer
- `@ARC-OPS-005` — SharePoint Information Architecture Model
- `@ARC-OPS-004` — Teams Governance Model
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@ARC-COMP-002` — Sensitive Data & Information Classification Model
- `@SYS-ENT-002` — Workload Entity Extension Map
- `@SYS-MAP-007` — Extension Dependency Map
- `@CAN-RUL-001` — Authority Inheritance Rules
- `@CAN-RUL-002` — Canonical Naming Enforcement
- `@CAN-GRP-002` — Framework Dependency Engine Model

## Depends On

- `@BLP-SYS-000` — Blueprint Control Layer
- `@ARC-OPS-005` — SharePoint Information Architecture Model
- `@ARC-OPS-004` — Teams Governance Model
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@ARC-COMP-002` — Sensitive Data & Information Classification Model
- `@SYS-STD-003` — Maturity Level Vocabulary
- `@SYS-STD-004` — Sector Template Vocabulary

## Feeds

- Future `MTX-SITES.csv`
- Future `MTX-LIBRARIES.csv`
- Future sensitivity and retention foundation templates
- Future access review blueprint patterns
- Future tenant documentation patterns

## Relationship Chain

```text
ARCH SharePoint IA
 -> BLP SharePoint Site Pattern
 -> Future MTX Site/Library Rows
 -> Future AUT Runtime Contract
```

Object relationship:

```text
Group
 -> Team
 -> SharePointSite
 -> Library
 -> Document category
```

## Blueprint Objectives

- Provide reusable site and library patterns for SME tenants.
- Preserve Team-backed site inheritance where appropriate.
- Make ownership visible before MTX generation.
- Keep document structure understandable and maintainable.
- Support basic sensitivity awareness without advanced Purview implementation.
- Prevent uncontrolled library and permission sprawl.

## Recommended Patterns

### Department Site Pattern

Use for a stable department Team.

Template fields:

```text
SitePattern: Department
ParentTeamPattern: Departmental
OwningDepartment: <DEPT-CODE>
PrimaryOwnerRole: <department lead role>
BackupOwnerRole: <backup owner role>
PermissionModel: Inherited
SensitivityDefault: INTERNAL
ReviewCadence: Quarterly
```

### Transversal Site Pattern

Use for cross-department operational work.

Template fields:

```text
SitePattern: Transversal
ParentTeamPattern: Transversal
OwningProcess: <process name>
ParticipatingDepartments: <department list>
PermissionModel: Inherited with controlled exceptions
SensitivityDefault: INTERNAL or CONFIDENTIAL
ReviewCadence: Quarterly
```

### Sensitive Library Pattern

Use for HR, Finance, security, or other sensitive document areas.

Template fields:

```text
LibraryPattern: Sensitive
ParentSite: <site pattern>
BusinessOwnerRole: <owner role>
AccessScope: Explicit group-based access
SensitivityDefault: CONFIDENTIAL or RESTRICTED
ReviewCadence: Quarterly or Monthly
Inheritance: Break only with documented justification
```

## Ownership Model

Each site pattern must define:

- business owner role
- operational owner role
- technical support owner role where needed
- review owner

Each sensitive library pattern must define:

- business owner role
- approved access scope
- review cadence
- sensitivity expectation

Owners resolve to actual users only at MTX layer.

## Review Model

Review must validate:

- site owner remains active
- library owner remains active
- permissions remain justified
- inheritance exceptions remain documented
- sensitive libraries are still correctly scoped
- unused or obsolete document areas are archived or cleaned up

Recommended cadence:

| Object | Cadence |
| --- | --- |
| Department site | Quarterly |
| Transversal site | Quarterly |
| Sensitive library | Monthly or Quarterly |
| Inheritance exception | Quarterly |
| Archive library | Quarterly or Semiannual |

## Naming Guidance

Use readable, searchable names aligned with existing naming doctrine.

Recommended semantic patterns:

```text
SITE-<DEPT-CODE>
SITE-<PROCESS>
LIB-<FUNCTION>
LIB-<SENSITIVITY>-<FUNCTION>
```

Folder naming may use the existing sortable pattern:

```text
NN-NAME
```

## Common Mistakes

- Creating a site without a Team, Group, owner, or purpose.
- Creating too many libraries for folder-level needs.
- Breaking permission inheritance without owner and review cadence.
- Assigning direct user permissions instead of group-based access.
- Treating SharePoint IA as Purview or DLP implementation.
- Storing sensitive content without clear ownership.

## Out of Scope

- Real site URLs
- Real tenant library names
- MTX rows
- AUT scripts
- Purview advanced labels
- DLP implementation
- Retention policy deployment
- Enterprise records management

## Integration Notes

This blueprint operationalizes `ARC-OPS-005` and remains subordinate to all ARC governance.

Future MTX generation must preserve:

```text
Team -> SharePointSite -> Library
```

This blueprint should be paired with `BLP-OPS-004` for Teams governance and `BLP-GOV-004` for access review patterns.
