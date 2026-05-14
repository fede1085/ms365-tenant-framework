---
id: "@SYS-STD-003"
domain: "Framework Ontology"
layer: "SYS"
type: "Standard"
status: "Active"
depends_on:
  - "@SYS-STD-001"
  - "@SYS-STD-002"
  - "@SYS-MAP-000"
  - "@ARC-STR-002"
authority_level: 1
---

# @SYS-STD-003 — Maturity Level Vocabulary

This document extends existing framework semantics and does not supersede prior SYS/CAN governance.

## Purpose

Define controlled vocabulary for tenant maturity levels used to scope framework application across learning, SMB tenant generation, SME governance, and future enterprise-oriented study.

Maturity Levels are filters of scope. They are not new layers and do not create independent architecture.

## Primary Layer

LAYER 1 — AI Semantic Navigation

## Ontology Owner

`@SYS`

## Scope

This vocabulary defines how much of the existing framework should be applied to a tenant scenario.

It controls language only. It does not create ARCH doctrine, BLP templates, MTX schemas, AUT contracts, or scripts.

## Governed By

- `@SYS-MAP-000` — Framework Ontology & Layer Model
- `@SYS-MAP-004` — Authority Map
- `@SYS-STD-001` — Canonical Vocabulary
- `@SYS-STD-002` — Naming System
- `@CAN-RUL-001` — Authority Inheritance Rules
- `@CAN-RUL-002` — Canonical Naming Enforcement

## Depends On

- `@SYS-STD-001` — Canonical Vocabulary
- `@SYS-STD-002` — Naming System
- `@SYS-MAP-000` — Framework Ontology & Layer Model
- `@ARC-STR-002` — Tenant Blueprint Factory Strategy

## Feeds

- Future maturity strategy architecture
- Future blueprint pack scoping
- Future matrix scope decisions
- Future learning path definitions
- Future validation checklists

## Entity/Term Definitions

### MaturityLevel

A semantic scope filter that defines how much governance, automation readiness, compliance modeling, and architectural depth should be applied to a tenant scenario.

MaturityLevel does not override architecture.

### SMB Basic

Baseline scope for small business tenant generation and basic Microsoft 365 study.

Typical focus:

- Users
- Departments
- Groups
- Shared Mailboxes
- Licenses
- Basic Teams
- Basic SharePoint via Teams
- MFA baseline
- Naming
- Ownership
- Simple permissions

Excluded by default:

- Advanced Purview
- Advanced DLP
- PIM
- Entitlement Management
- Complex retention design
- Enterprise audit maturity

### SME Governance

Governance-oriented scope for small and medium organizations that need stronger control without enterprise complexity.

Typical focus:

- Ownership and backup ownership
- Joiner/Mover/Leaver governance
- Teams governance
- SharePoint information architecture
- Access reviews
- Guest governance
- Conditional Access baseline
- Admin role separation
- Sensitivity and retention foundations
- Audit review cadence

### Enterprise Thinking

Advanced study and architecture-thinking scope used to understand enterprise patterns without making them mandatory for SMB or SME tenants.

Typical focus:

- Advanced access governance concepts
- Advanced information protection concepts
- Privileged access models
- Regulatory scenarios
- Audit maturity
- Sector-specific compliance thinking
- Future Purview/DLP planning

Enterprise Thinking is a learning and architectural expansion mode. It is not the default execution baseline.

## Relationship Chain

```text
MaturityLevel
 -> Scope decision
 -> ARCH applicability
 -> BLP template selection
 -> MTX matrix scope
 -> AUT readiness boundary
```

Maturity levels must preserve:

```text
SYS/CAN -> ARCH -> BLP -> MTX -> AUT
```

## Out of Scope

- New framework layers
- Independent maturity frameworks
- Scoring engines
- Automated maturity assessment
- Enterprise controls as default SMB requirements
- Security or compliance implementation details

## Integration Notes

Use MaturityLevel to prevent overengineering.

Recommended interpretation:

- SMB Basic = build and learn core Microsoft 365 structure.
- SME Governance = add sustainable governance.
- Enterprise Thinking = study advanced patterns without forcing implementation.

Future ARCH and BLP documents may reference these terms to declare intended scope.
