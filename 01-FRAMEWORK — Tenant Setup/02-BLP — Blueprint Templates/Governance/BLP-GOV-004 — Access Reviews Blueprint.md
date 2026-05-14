---
id: "@BLP-GOV-004"
domain: "Governance"
layer: "BLP"
type: "Blueprint"
status: "Active"
depends_on:
  - "@BLP-SYS-000"
  - "@ARC-GOV-004"
  - "@ARC-GOV-002"
  - "@ARC-GOV-016"
  - "@ARC-OPS-004"
  - "@ARC-OPS-005"
  - "@SYS-ENT-002"
  - "@SYS-MAP-007"
  - "@SYS-STD-003"
  - "@SYS-STD-004"
  - "@CAN-RUL-001"
  - "@CAN-RUL-002"
  - "@CAN-GRP-001"
  - "@CAN-GRP-002"
authority_level: 3
---

# BLP-GOV-004 — Access Reviews Blueprint

This blueprint operationalizes existing ARC doctrine and does not supersede architectural governance.

## Purpose

Translate access review governance into reusable blueprint patterns for review cadence, orphan detection, guest review, admin review, least privilege review, and governance workflow design.

This blueprint defines review patterns only. It does not implement Entra Access Reviews or automate access removal.

## Primary Layer

LAYER 3 — Tenant Conceptual Modeling

## Secondary Layer

LAYER 4 — Tenant Operational Execution Preparation

## Ontology Owner

`@BLP`

## Scope

This blueprint covers review patterns for:

- Groups
- Teams
- Shared Mailboxes
- SharePoint sites
- SharePoint libraries
- Guest users
- Admin role assignments
- sensitive access

It contains reusable governance patterns only and must not contain real tenant data.

## Governed By

- `@ARC-SYS-000` — Architecture Control Map
- `@BLP-SYS-000` — Blueprint Control Layer
- `@ARC-GOV-004` — Access Review Governance Model
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@ARC-GOV-016` — User Lifecycle Model
- `@ARC-OPS-004` — Teams Governance Model
- `@ARC-OPS-005` — SharePoint Information Architecture Model
- `@SYS-ENT-002` — Workload Entity Extension Map
- `@SYS-MAP-007` — Extension Dependency Map
- `@CAN-RUL-001` — Authority Inheritance Rules
- `@CAN-RUL-002` — Canonical Naming Enforcement
- `@CAN-GRP-001` — Semantic Dependency Graph
- `@CAN-GRP-002` — Framework Dependency Engine Model

## Depends On

- `@BLP-SYS-000` — Blueprint Control Layer
- `@ARC-GOV-004` — Access Review Governance Model
- `@ARC-GOV-002` — Access Governance & Ownership Model
- `@ARC-GOV-016` — User Lifecycle Model
- `@ARC-OPS-004` — Teams Governance Model
- `@ARC-OPS-005` — SharePoint Information Architecture Model
- `@SYS-STD-003` — Maturity Level Vocabulary
- `@SYS-STD-004` — Sector Template Vocabulary

## Feeds

- Future `MTX-ACCESS-REVIEWS.csv`
- Future validation report patterns
- Future governance checklist templates
- Future guest review patterns
- Future admin role review patterns
- Future audit maturity patterns

## Relationship Chain

```text
ARCH Access Review Governance
 -> BLP Access Review Pattern
 -> Future MTX Review Rows
 -> Future Validation/Audit Output
```

Review relationship:

```text
Resource
 -> Owner
 -> Reviewer
 -> ReviewCadence
 -> ReviewDecision
 -> RemediationAction
```

## Blueprint Objectives

- Define reusable review patterns before tenant-specific matrices exist.
- Make ownership and reviewer accountability explicit.
- Detect orphaned resources and stale access.
- Support least privilege through periodic validation.
- Keep review workflows manual and governance-oriented until automation is explicitly introduced.
- Avoid confusing governance review patterns with Entra Access Reviews implementation.

## Recommended Patterns

### Standard Resource Review Pattern

Use for Teams, Groups, Shared Mailboxes, and standard SharePoint areas.

Template fields:

```text
ReviewPattern: StandardResource
ResourceType: <Group/Team/SharedMailbox/Site/Library>
OwnerRole: <resource owner role>
ReviewerRole: <reviewer role>
ReviewCadence: Quarterly
DecisionOptions: Keep/Remove/Reduce/Escalate
OrphanCheck: Required
```

### Guest Access Review Pattern

Use for external identities and guest-enabled Teams or sites.

Template fields:

```text
ReviewPattern: GuestAccess
GuestSponsorRole: <sponsor role>
ResourceType: <Team/Site/Library>
ReviewCadence: Quarterly
DecisionOptions: Continue/Expire/Reduce/Escalate
ScopeValidation: Required
```

### Admin Role Review Pattern

Use for privileged or administrative roles.

Template fields:

```text
ReviewPattern: AdminRole
AdminRoleType: <role type>
ReviewerRole: <IT/security reviewer role>
ReviewCadence: Monthly
DecisionOptions: Keep/Remove/Reduce/Escalate
ProtectedObjectCheck: Required
```

### Sensitive Access Review Pattern

Use for restricted libraries, finance, HR, security, or other sensitive areas.

Template fields:

```text
ReviewPattern: SensitiveAccess
ResourceType: <Mailbox/Site/Library/Group>
Sensitivity: <CONFIDENTIAL/RESTRICTED>
ReviewerRole: <owner or security reviewer role>
ReviewCadence: Monthly or Quarterly
DecisionOptions: Keep/Remove/Reduce/Escalate
```

## Ownership Model

Each review pattern must define:

- resource owner role
- reviewer role
- escalation owner role where needed
- guest sponsor role where guests exist
- technical reviewer role for privileged or sensitive access

Review ownership resolves to actual users only at MTX layer.

## Review Model

Each review must answer:

```text
Is access still required?
Is access correctly scoped?
Is the resource still owned?
Is the reviewer accountable?
Is access excessive?
Is guest or privileged access still justified?
Should access be removed, reduced, retained, or escalated?
```

Recommended cadence:

| Pattern | Cadence |
| --- | --- |
| StandardResource | Quarterly |
| GuestAccess | Quarterly |
| AdminRole | Monthly |
| SensitiveAccess | Monthly or Quarterly |
| OrphanedResource | On detection |

## Naming Guidance

Use existing naming standards and keep review names tied to resource type and purpose.

Recommended semantic patterns:

```text
REV-<RESOURCE-TYPE>-<SCOPE>
REV-GUEST-<SCOPE>
REV-ADMIN-<ROLE>
REV-SENSITIVE-<SCOPE>
```

Actual review object names are future MTX concerns.

## Common Mistakes

- Treating this blueprint as Entra Access Reviews automation.
- Reviewing access without a named accountable reviewer.
- Skipping owner validation.
- Keeping guest access indefinitely without sponsor validation.
- Reviewing admin roles on the same cadence as standard access.
- Removing access automatically without governance approval.
- Ignoring orphaned resources until audit time.

## Out of Scope

- Entra Access Reviews implementation
- Entitlement Management
- PIM
- PowerShell or Microsoft Graph scripts
- MTX rows
- AUT runtime contracts
- automatic access removal
- compliance audit tooling

## Integration Notes

This blueprint operationalizes `ARC-GOV-004` and remains subordinate to all ARC governance.

Future MTX generation must preserve:

```text
Resource -> Owner -> Reviewer -> ReviewDecision
```

This blueprint should be paired with Teams and SharePoint blueprint patterns to ensure resource reviews are generated from real collaboration and information architecture scope.
