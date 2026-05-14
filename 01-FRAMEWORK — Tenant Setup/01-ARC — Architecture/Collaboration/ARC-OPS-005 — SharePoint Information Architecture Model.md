---
id: "@ARC-OPS-005"
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
  - "@ARC-OPS-004"
  - "@ARC-GOV-002"
  - "@ARC-COMP-002"
  - "@CAN-RUL-001"
  - "@CAN-RUL-002"
  - "@CAN-GRP-002"
authority_level: 1
---

# ARC-OPS-005 — SharePoint Information Architecture Model

This document extends existing architecture and does not supersede prior ARC governance.

## Purpose

Define SharePoint as the tenant information architecture layer for structured documents, ownership, inheritance, segmentation, and SME-operable document organization.

This document establishes the conceptual relationship between Teams, SharePoint sites, document libraries, permissions, and basic sensitivity inheritance.

## Primary Layer

LAYER 2 — Framework Meta-Architecture

## Secondary Layer

LAYER 3 — Tenant Conceptual Modeling

## Ontology Owner

`@ARC`

## Scope

This document covers:

- SharePoint as information architecture
- Team to Site to Library relationship
- site and library ownership
- permission inheritance
- document segmentation
- SME document structure
- conceptual sensitivity inheritance

It does not define Purview, DLP, retention execution, or SharePoint automation.

## Governed By

- `@SYS-MAP-000` — Framework Ontology & Layer Model
- `@SYS-MAP-004` — Authority Map
- `@SYS-ENT-002` — Workload Entity Extension Map
- `@SYS-MAP-007` — Extension Dependency Map
- `@ARC-SYS-000` — Architecture Control Map
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@ARC-COMP-002` — Sensitive Data & Information Classification Model
- `@CAN-RUL-001` — Authority Inheritance Rules
- `@CAN-RUL-002` — Canonical Naming Enforcement
- `@CAN-GRP-002` — Framework Dependency Engine Model

## Depends On

- `@ARC-OPS-001` — Collaboration Operating Model
- `@ARC-OPS-004` — Teams Governance Model
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@ARC-COMP-002` — Sensitive Data & Information Classification Model
- `@SYS-ENT-002` — Workload Entity Extension Map
- `@SYS-MAP-007` — Extension Dependency Map
- `@SYS-STD-003` — Maturity Level Vocabulary

## Feeds

- Future SharePoint sites blueprint templates
- Future library matrix definitions
- Future sensitivity and retention foundation templates
- Future access review governance
- Future tenant documentation models

## Relationship Chain

```text
Tenant
 -> Department
   -> Group
      -> Team
         -> SharePointSite
            -> Library
               -> Documents
```

Information protection relationship:

```text
Library
 -> Document category
 -> Sensitivity expectation
 -> Retention expectation
 -> Access review scope
```

## Governance Principles

- SharePoint is the structured document layer of the collaboration model.
- Team-backed SharePoint sites inherit business context from the Team and its Microsoft 365 Group.
- Site ownership must align with Team or business ownership.
- Libraries should segment documents by function, sensitivity, lifecycle, or operational workflow.
- Permission inheritance is preferred unless a clear business reason requires a controlled exception.
- Direct user permissions should be avoided where group-based access is possible.
- Sensitive document areas must have explicit owner and review expectations.
- SME information architecture must stay simple, readable, and operationally maintainable.

## Operational Model

### Team-Backed Site Model

For standard departmental collaboration:

```text
Department
 -> Microsoft 365 Group
 -> Team
 -> SharePoint Site
```

The SharePoint site stores department and Team documents.

### Library Model

Libraries should represent stable document categories.

Common SME examples:

```text
01-Operations
02-Projects
03-Finance
04-HR
05-Policies
99-Archive
```

Libraries should not be created for every small folder need. Folder structure should remain subordinate to library purpose.

### Ownership Model

Each site should have:

- business owner
- operational owner
- technical support owner where needed

Each sensitive library should have:

- clear business owner
- defined access scope
- review expectation

### Permission Inheritance

Default model:

```text
Group membership
 -> Team membership
 -> SharePoint site access
 -> Library access
```

Breaking inheritance is allowed only when:

- sensitivity requires it
- business need is documented
- owner is assigned
- review cadence is defined

### Document Segmentation

Documents should be segmented by:

- department
- workflow
- project
- sensitivity
- retention need

Segmentation should make ownership and access visible.

### Conceptual Sensitivity

SharePoint IA must support basic sensitivity awareness:

```text
PUBLIC
INTERNAL
CONFIDENTIAL
RESTRICTED
```

This is conceptual classification only. It does not imply Purview label deployment.

## Out of Scope

- Purview advanced configuration
- DLP implementation
- retention policy execution
- SharePoint provisioning scripts
- BLP templates
- MTX schemas
- AUT runtime contracts
- complex enterprise records management

## Integration Notes

This document depends on Teams governance because Team-backed sites inherit collaboration context from Groups and Teams.

Future SharePoint templates must preserve:

```text
Group -> Team -> SharePointSite -> Library
```

Future compliance work must not bypass this information architecture model when defining sensitivity or retention foundations.
