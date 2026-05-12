# @SYS-MAP-001 — Master Index

> **Purpose:** Global framework index to simulate semantic folder hierarchy for AI systems.

## 1. Domains
- @DOMAIN-IDENTITY (Identity & Access Management)
- @DOMAIN-COLLABORATION (Teams, SharePoint, OneDrive)
- @DOMAIN-MESSAGING (Exchange, Mail routing)
- @DOMAIN-DEVICES (Intune, Endpoint Management)
- @DOMAIN-SECURITY (Defender, Purview, Compliance)

## 2. Layers
- @LAYER-ARC (Architecture & Rules)
- @LAYER-BLP (Blueprint & Templates)
- @LAYER-MTX (Matrix & Data)
- @LAYER-AUT (Automation & Scripts)

## 3. Modules
- @MOD-USERS (User Lifecycle Management)
- @MOD-GROUPS (Security & Microsoft 365 Groups)
- @MOD-MAILBOXES (Shared Mailboxes & Delegation)
- @MOD-LICENSES (License Assignment Rules)

## 4. Architecture Files
- @ARC-SYS-000 (Architecture Control Map)
- @ARC-STD-007 (Naming Convention Standard)
- @ARC-STD-014 (Security Baseline)

## 5. Blueprint Files
- @BLP-SYS-000 (Blueprint Control Layer)
- @BLP-TMP-002 (Department Matrix Template)
- @BLP-TMP-003 (User Matrix Template)
- @BLP-TMP-004 (Group Matrix Template)
- @BLP-TMP-005 (Shared Mailbox Matrix Template)
- @BLP-TMP-006 (Permission Matrix Template)
- @BLP-TMP-015 (License Matrix Template)

## 6. Matrix Files
- @MTX-USR-001 (User Mapping Matrix - Instance)
- @MTX-GRP-001 (Group Mapping Matrix - Instance)
- @MTX-MBX-001 (Shared Mailbox Matrix - Instance)
- @MTX-PRM-001 (Permission & Access Matrix - Instance)

## 7. Standards
- @ARC-STD-014 (Security Baseline)
- @ARC-STD-017 (Documentation Framework)

## 8. Governance Documents
- @ARC-GOV-016 (User Lifecycle Model)
- @BLP-TMP-015 (License Matrix Template)
- @SYS-GOV-003 (Authority Layer Clarification)


## 9. Legacy Documents
- LEGACY-prefixed documents are **historical reference only**.
- Legacy documents are **non-authoritative** for active governance decisions.
- Do not use legacy artifacts as source-of-truth for current SYS/CAN/ARC enforcement.

## 10. Canonical Derivative Layer Clarification
- `03-COMPILED` = derived machine-readable semantic compilations; not semantic authorities.
- `04-GRAPHS` = dependency/routing visualization derived from SYS/CAN.
- `05-ROUTING` = context-loading and orchestration routing layer.
- `06-AUDITS` = verification and synchronization reports; read-only analytical outputs.

## 11. Auxiliary Workspace Clarification
- `.codex` is an AI-assisted tooling workspace.
- `.codex` is non-authoritative and outside of framework ontology discussion
- `.codex` as a tooling infrastructure must stay outside ontology
