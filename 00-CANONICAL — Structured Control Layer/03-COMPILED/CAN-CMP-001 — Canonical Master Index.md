---
id: "@CAN-CMP-001"
domain: "Framework Ontology"
layer: "CAN"
type: "Index"
status: "Active"
depends_on:
  - "@SYS-MAP-001"
authority_level: 1
---

# @CAN-CMP-001 — Canonical Master Index

> **Purpose:** A compiled, deterministic index representation of `@SYS-MAP-001` optimized for AI Retrieval.

## 1. System & Canonical Nodes

```json
{
  "System": [
    "@SYS-MAP-000", "@SYS-MAP-001", "@SYS-MAP-002", "@SYS-MAP-003",
    "@SYS-MAP-004", "@SYS-MAP-005", "@SYS-MAP-006", "@SYS-GOV-001",
    "@SYS-GOV-002", "@SYS-STD-001", "@SYS-STD-002", "@SYS-STD-003",
    "@SYS-STD-004", "@SYS-ENT-002", "@SYS-MAP-007", "@SYS-TPL-001"
  ],
  "Canonical": [
    "@CAN-SCH-001", "@CAN-SCH-002", "@CAN-RUL-001", "@CAN-RUL-002",
    "@CAN-CMP-001", "@CAN-GRP-001", "@CAN-RTE-001"
  ]
}
```

## 2. Core Execution Nodes

```json
{
  "Architecture": [
    "@ARC-SYS-000", "@ARC-STD-007", "@ARC-STD-014", "@ARC-STD-017", "@ARC-GOV-016",
    "@ARC-OPS-004", "@ARC-OPS-005", "@ARC-GOV-004"
  ],
  "Blueprint": [
    "@BLP-SYS-000", "@BLP-TMP-002", "@BLP-TMP-003", "@BLP-TMP-004",
    "@BLP-TMP-005", "@BLP-TMP-006", "@BLP-TMP-015",
    "@BLP-OPS-004", "@BLP-OPS-005", "@BLP-GOV-004"
  ]
}
```

## 3. Compiled Objects Registry

All compiled canonical objects (YAML + JSON pairs) registered below. These are machine-readable representations of their SYS semantic sources.

| Compiled ID | Source | YAML | JSON |
| :--- | :--- | :--- | :--- |
| `@SYS-MAP-000` | SYS-MAP-000 — Framework Ontology | ✅ | ✅ |
| `@SYS-MAP-001` | SYS-MAP-001 — Master Index | ✅ | ✅ |
| `@SYS-MAP-002` | SYS-MAP-002 — Relations Map | ✅ | ✅ |
| `@SYS-MAP-004` | SYS-MAP-004 — Authority Map | ✅ | ✅ |
| `@SYS-MAP-007` | SYS-MAP-007 — Extension Dependency Map | ✅ | ✅ |
| `@SYS-ENT-002` | SYS-ENT-002 — Workload Entity Extension Map | ✅ | ✅ |
| `@SYS-GOV-001` | SYS-GOV-001 — Read First | ✅ | ✅ |
| `@SYS-GOV-002` | SYS-GOV-002 — Context Loading Priority | ✅ | ✅ |
| `@SYS-STD-001` | SYS-STD-001 — Canonical Vocabulary | ✅ | ✅ |
| `@SYS-STD-002` | SYS-STD-002 — Naming System | ✅ | ✅ |
| `@SYS-STD-003` | SYS-STD-003 — Maturity Level Vocabulary | ✅ | ✅ |
| `@SYS-STD-004` | SYS-STD-004 — Sector Template Vocabulary | ✅ | ✅ |
| `@SYS-TPL-001` | SYS-TPL-001 — Metadata Template | ✅ | ✅ |

## 4. Node Registration Rule

New files are not officially part of the framework until their `@ID` is registered in `SYS-MAP-001` and compiled into `CAN-CMP-001`.

