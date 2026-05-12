---
id: "@CAN-RTE-001"
domain: "Framework Ontology"
layer: "CAN"
type: "Router"
status: "Active"
depends_on:
  - "@SYS-GOV-002"
  - "@SYS-MAP-006"
compiled_equivalent: "SYS-CONTEXT.router.yaml"
authority_level: 1
---

# @CAN-RTE-001 — Context Loading Router

> **Purpose:** Execution logic for AI context window management, derived from `@SYS-GOV-002` and aligned to the workflow sequence defined in `@SYS-MAP-006`. Ensures AI does not load irrelevant data causing token saturation and semantic drift.
>
> **Compiled Equivalent:** `SYS-CONTEXT.router.yaml` — the machine-readable enforcement representation of this document. Both files must remain semantically identical. If conflict arises, this document (CAN-RTE-001.md) is the human-semantic authority; `SYS-CONTEXT.router.yaml` is the machine-enforcement layer.

## 1. Initialization Sequence

Whenever a new Agent session begins, this router dictates the immediate loading sequence before answering user queries.

1. **Load System Map:** Read `@SYS-MAP-000` and `@CAN-SCH-002`.
2. **Load Vocabulary:** Read `@SYS-STD-001` and `@SYS-STD-002`.
3. **Parse Request:** Determine the task abstraction layer (ARC, BLP, MTX, AUT).

## 2. Dynamic Routing Logic

### If Task = "Create new tenant" (MTX Generation)
- **Do not load:** `AUT-*` (Not ready).
- **Load:** `BLP-TMP-*` (Templates needed).
- **Load:** `ARC-STD-*` (Rules needed).

### If Task = "Write Automation Script" (AUT Generation)
- **Do not load:** `BLP-TMP-*` (Too abstract).
- **Load:** `MTX-*` (Need specific data schema to write script).
- **Load:** `ARC-STD-007` (Need naming rules for output).

### If Task = "Define Framework Rules" (ARC Modification)
- **Do not load:** `MTX-*` (Client data must not influence core architecture).
- **Load:** `SYS-MAP-*` and `CAN-*` (To ensure systemic safety).

## 3. Grounding Mandate
An AI Agent must NEVER generate an output that violates the Context Loading Priority or pulls domain knowledge from outside the loaded context without explicit user consent.

## 4. Execution State Safety Gate

Router behavior MUST respect explicit execution states:
- `READ_ONLY`: inspection/validation only; no generation and no execution actions.
- `PLAN`: planning/analysis only; no file writes.
- `GENERATE`: controlled artifact generation only when explicitly requested.
- `EXECUTE`: reserved for AUT layer operations.

If user intent is audit, inspection, or semantic validation, enforce `READ_ONLY`.
