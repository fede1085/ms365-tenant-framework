---
id: "@SYS-STD-004"
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

# @SYS-STD-004 — Sector Template Vocabulary

This document extends existing framework semantics and does not supersede prior SYS/CAN governance.

## Purpose

Define controlled vocabulary for sector templates so future tenant scenarios can vary by business type without creating parallel frameworks or independent ontology branches.

Sector Templates parametrize the existing framework. They do not replace it.

## Primary Layer

LAYER 1 — AI Semantic Navigation

## Ontology Owner

`@SYS`

## Scope

This vocabulary supports future sector-specific blueprint work for study, tenant generation, and architecture analysis.

It defines semantic labels and variation boundaries only. It does not define full sector architecture, compliance programs, BLP templates, MTX data, or automation.

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

- Future sector strategy architecture
- Future sector blueprint packs
- Future project discovery prompts
- Future learning scenarios
- Future matrix generation constraints

## Entity/Term Definitions

### SectorTemplate

A reusable semantic variation profile for a business type.

SectorTemplate may influence:

- department defaults
- role defaults
- mailbox patterns
- Teams collaboration patterns
- SharePoint information architecture emphasis
- access review priority
- sensitivity and retention emphasis

SectorTemplate must not redefine core framework layers.

### Logistics

SectorTemplate for logistics, transport, warehouse, dispatch, and operational coordination scenarios.

Common emphasis:

- Operations
- Warehouse
- Dispatch
- Support
- route coordination
- customer issue workflow

### Consulting

SectorTemplate for advisory, professional services, and client project organizations.

Common emphasis:

- client workspaces
- project Teams
- controlled guest access
- document collaboration
- knowledge reuse

### Legal

SectorTemplate for legal service environments.

Common emphasis:

- matter-based workspaces
- confidentiality
- restricted access
- document retention
- external collaboration control

### Healthcare

SectorTemplate for clinical, care, or health service environments.

Common emphasis:

- sensitive data handling
- restricted sharing
- strong audit expectations
- role-based access
- retention awareness

### Administrative Services

SectorTemplate for back-office, administration, accounting support, and process-heavy organizations.

Common emphasis:

- process mailboxes
- structured document libraries
- approval workflows
- retention consistency

### General Services

SectorTemplate for service companies with support, operations, sales, and field/service coordination.

Common emphasis:

- shared mailboxes
- support workflows
- service teams
- operational documentation

## Relationship Chain

```text
SectorTemplate
 -> Business scenario
 -> Department defaults
 -> Role defaults
 -> Collaboration defaults
 -> Governance emphasis
 -> Blueprint guidance
 -> Matrix generation constraints
```

SectorTemplate must remain inside the existing chain:

```text
SYS/CAN -> ARCH -> BLP -> MTX -> AUT
```

## Out of Scope

- Sector-specific compliance implementation
- Full legal, healthcare, or financial regulatory frameworks
- Independent sector ontologies
- New root folders
- BLP sector packs
- MTX sector data
- Automation logic
- Purview or DLP implementation

## Integration Notes

Sector Templates should be treated as controlled variation inputs during discovery and blueprint generation.

They may change emphasis, defaults, and examples, but they must not:

- redefine core entities
- bypass naming standards
- bypass authority inheritance
- create alternate execution flows
- make enterprise controls mandatory for SMB Basic scenarios
