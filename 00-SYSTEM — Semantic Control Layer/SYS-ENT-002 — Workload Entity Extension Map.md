---
id: "@SYS-ENT-002"
domain: "Framework Ontology"
layer: "SYS"
type: "Entity Map"
status: "Active"
depends_on:
  - "@SYS-ENT-001"
  - "@SYS-STD-001"
  - "@SYS-MAP-000"
  - "@CAN-GRP-002"
authority_level: 1
---

# @SYS-ENT-002 — Workload Entity Extension Map

This document extends existing framework semantics and does not supersede prior SYS/CAN governance.

## Purpose

Define additional Microsoft 365 workload entities required for future framework extensions while keeping them subordinate to the core entities already defined by `@SYS-ENT-001`.

This document does not redefine Tenant, User, Group, Role, Permission, Shared Mailbox, Blueprint, or Matrix.

## Primary Layer

LAYER 1 — AI Semantic Navigation

## Ontology Owner

`@SYS`

## Scope

This map covers workload-level entities used by collaboration, information architecture, governance, security, compliance foundations, sector templates, and maturity levels.

The entities are semantic routing constructs only. They do not create execution behavior, automation logic, or tenant instance data.

## Governed By

- `@SYS-MAP-000` — Framework Ontology & Layer Model
- `@SYS-MAP-004` — Authority Map
- `@SYS-STD-001` — Canonical Vocabulary
- `@SYS-STD-002` — Naming System
- `@CAN-RUL-001` — Authority Inheritance Rules
- `@CAN-RUL-002` — Canonical Naming Enforcement
- `@CAN-GRP-002` — Framework Dependency Engine Model

## Depends On

- `@SYS-ENT-001` — Entity Map
- `@SYS-MAP-000` — Framework Ontology & Layer Model
- `@SYS-STD-001` — Canonical Vocabulary
- `@CAN-GRP-002` — Framework Dependency Engine Model

## Feeds

- Future `ARC-OPS-*` collaboration architecture
- Future `ARC-GOV-*` governance architecture
- Future `ARC-SEC-*` security architecture
- Future `ARC-COMP-*` compliance foundation architecture
- Future `BLP-*` blueprint templates
- Future `MTX-*` instance matrices

## Entity/Term Definitions

### Team

A Microsoft Teams collaboration workspace derived from a Microsoft 365 Group.

Core dependency:

```text
Group -> Team
```

A Team is not the root access object. The associated Group remains the identity and membership container.

### Channel

A collaboration subdivision inside a Team.

Channels inherit governance from the parent Team unless a future architecture document defines stricter rules for private or shared channels.

Core dependency:

```text
Team -> Channel
```

### SharePointSite

A SharePoint site that stores and organizes documents, often provisioned as part of a Team-backed Microsoft 365 Group.

Core dependency:

```text
Group -> Team -> SharePointSite
```

### Library

A document container inside a SharePointSite.

Libraries segment documents by function, retention need, ownership, or operational workflow.

Core dependency:

```text
SharePointSite -> Library
```

### GuestUser

An external identity granted controlled access to tenant collaboration resources.

A GuestUser must have a sponsor, scope, and review expectation.

Core dependency:

```text
Tenant -> GuestUser -> Sponsor -> AccessReview
```

### AccessReview

A governance control used to validate whether access remains required, justified, owned, and aligned with least privilege.

AccessReview applies to Groups, Teams, Shared Mailboxes, admin role assignments, guest users, and sensitive access.

### ConditionalAccessPolicy

A security policy that evaluates identity, role, device, location, risk, and workload access context.

This entity remains conceptual until an ARCH/BLP/MTX chain defines operational structure.

### AdminRoleAssignment

A privileged role assignment granted to an administrative identity.

AdminRoleAssignment must remain distinct from business Role and technical Permission.

### SensitivityLabel

A classification and protection marker applied to information, containers, or documents.

SensitivityLabel is conceptual in this semantic map and does not imply Purview automation.

### RetentionPolicy

A governance rule that defines how long information must be retained, reviewed, or disposed.

RetentionPolicy depends on information classification, business need, and applicable compliance requirements.

### SectorTemplate

A controlled variation pattern for adapting the framework to an industry or business type.

SectorTemplate parametrizes the framework. It does not create a parallel architecture.

### MaturityLevel

A controlled scope filter that defines how much of the framework should be applied to a tenant scenario.

MaturityLevel is not a new layer.

## Relationship Chain

```text
Tenant
 -> Department
   -> User
   -> Group
      -> Team
         -> Channel
         -> SharePointSite
            -> Library
   -> SharedMailbox
   -> Role
      -> Permission
      -> AdminRoleAssignment
   -> GuestUser
      -> AccessReview
```

Compliance and policy relationship:

```text
Library -> SensitivityLabel -> RetentionPolicy
User/Group/AdminRoleAssignment/GuestUser -> ConditionalAccessPolicy
Group/Team/SharedMailbox/GuestUser/AdminRoleAssignment -> AccessReview
```

Strategy relationship:

```text
SectorTemplate -> Department/Role/Workflow defaults
MaturityLevel -> Module scope filter
```

## Out of Scope

- New ARCH doctrine
- Blueprint templates
- MTX schemas
- AUT runtime contracts
- Scripts
- Purview advanced configuration
- DLP implementation
- PIM or entitlement management implementation
- Any change to core entity definitions in `@SYS-ENT-001`

## Integration Notes

These entities must be used as semantic extensions only until corresponding `ARCH`, `BLP`, `MTX`, and `AUT` documents are explicitly created.

All future documents referencing these entities must preserve:

```text
SYS/CAN -> ARCH -> BLP -> MTX -> AUT
```

No workload entity may bypass Group, User, Department, Role, Permission, or Tenant governance where those core entities already apply.
