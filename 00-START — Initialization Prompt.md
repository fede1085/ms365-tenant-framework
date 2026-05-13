# Initialize new tenant project: [project_name]

Use Agent Mode.

---

# EXECUTION STATE

Current execution state:

```text
READ_ONLY
```

Allowed behaviors in READ_ONLY:

- inspection
- discovery
- semantic analysis
- governance validation
- architecture review
- workflow review
- reporting

Forbidden behaviors in READ_ONLY:

- modifying framework files
- generating MTX
- generating AUT
- deployment execution
- PowerShell execution
- tenant modification
- automatic progression into execution phases

Execution-state progression must remain HUMAN-SUPERVISED.

Allowed operational states:

```text
READ_ONLY
PLAN
GENERATE
EXECUTE
```

The system must NEVER escalate execution state automatically.

---

# SOURCE FOLDERS

Read framework governance and semantic rules from:

@00-SYSTEM — Semantic Control Layer
@00-CANONICAL — Structured Control Layer
@.agents\rules
@.agents\workflows
@01-FRAMEWORK — Tenant Setup\01-ARC — Architecture
@01-FRAMEWORK — Tenant Setup\02-BLP — Blueprint Templates
@01-FRAMEWORK — Tenant Setup\04-AUT — Automation Executables

All framework sources are STRICT READ-ONLY.

Do NOT modify framework files.

---

# CORE MODEL

Follow strictly:

```text
ARCH → BLP → MTX → AUT
```

Definitions:

- ARCH = governance and architecture doctrine
- BLP = operational blueprint layer
- MTX = execution-ready operational data
- AUT = deployment and automation layer

Additional orchestration flow:

```text
DISCOVERY
→ PRJ-BLUEPRINT-MASTER-DOC
→ DOMAIN BLP
→ VALIDATION
→ MTX
→ VALIDATION
→ AUT
```

Each phase requires explicit approval before continuation.

---

# ONTOLOGY SEPARATION

Maintain strict ontology boundaries between:

## 1. META-FRAMEWORK ONTOLOGY

Includes:

- SYS
- CAN
- ARCH
- BLP governance
- AUT governance
- routing logic
- semantic governance
- canonical enforcement

Represents:

- framework doctrine
- semantic architecture
- governance system
- reusable operational standards

---

## 2. TENANT INSTANCE ONTOLOGY

Includes:

- tenant operational structure
- tenant business logic
- PRJ files
- generated BLP documents
- MTX files
- users
- groups
- shared mailboxes
- permissions
- operational workflows

Represents:

- real or simulated tenant operational state

---

# IMPORTANT ONTOLOGY RULE

Framework ontology is STRICT READ-ONLY during tenant generation.

Tenant generation must NEVER:

- modify SYS
- modify CAN
- modify ARCH
- redefine framework governance
- redefine semantic meaning
- redefine canonical meaning

Tenant operational data belongs ONLY to tenant ontology.

Framework governance must NEVER be copied into tenant instance files as authoritative architecture.

---

# SEMANTIC / CANONICAL GOVERNANCE

Semantic governance originates from:

```text
00-SYSTEM
```

Canonical enforcement derives from:

```text
00-CANONICAL
```

Important principle:

```text
CAN derives from SYS
CAN does NOT redefine SYS
```

Canonical files must NEVER invent governance, ontology, authority, or semantic meaning not declared in semantic source files.

---

# STEP 1 — INTERACTIVE DISCOVERY

Execution state required:

```text
PLAN
```

Execute interactive business discovery workflow.

---

## DISCOVERY GOAL

Define:

- company structure
- departments
- operational workflows
- collaboration logic
- user roles
- users
- groups
- shared mailboxes
- permissions
- ownership
- escalation paths
- licenses
- governance needs
- security posture

---

## DISCOVERY RULES

- Ask step-by-step
- Do NOT skip phases
- Prioritize operational realism
- Do NOT infer enterprise complexity unless required
- Do NOT generate CSV yet
- Do NOT generate MTX yet
- Do NOT generate AUT
- Do NOT run scripts
- Do NOT deploy anything

Focus on:

```text
how the organization actually operates
```

NOT only technical structure.

---

# STEP 2 — GENERATE PROJECT STRUCTURE

Execution state required:

```text
GENERATE
```

Create:

```text
02-INSTANCES — Projects\[project_name]\
    ├── 01-DISCOVERY — Discovery
    ├── 02-BLP — Blueprint Templates
    ├── 03-MTX — Data Matrices
    └── 04-AUT — Automation Executables
```

Do NOT generate framework architecture folders inside tenant instances.

Do NOT generate:

```text
01-ARC
00-SYSTEM
00-CANONICAL
```

inside tenant projects.

Framework architecture remains external and authoritative.

---

# STEP 3 — GENERATE MASTER OPERATIONAL BLUEPRINT

Generate:

```text
PRJ-BLUEPRINT-MASTER-DOC.md
```

inside:

```text
02-INSTANCES — Projects\[project_name]\02-BLP
```

---

# MASTER DOCUMENT PURPOSE

This document becomes:

```text
tenant operational source of truth
```

for the tenant instance only.

The MASTER document consolidates:

- organizational structure
- departments
- operational relationships
- user roles
- collaboration patterns
- Teams operational behavior
- mailbox ownership
- escalation logic
- lifecycle logic
- governance requirements
- security posture
- operational handoffs

---

# MASTER RULES

- MASTER belongs to tenant ontology only
- Do NOT modify framework architecture
- Do NOT generate MTX yet
- Do NOT generate AUT yet
- Do NOT create deployment logic
- Do NOT continue automatically

Stop after MASTER generation.

Wait for validation approval.

---

# STEP 4 — GENERATE DOMAIN BLUEPRINT LAYER

Execution state required:

```text
GENERATE
```

ONLY after explicit approval.

Generate specialized Blueprint documents from:

```text
PRJ-BLUEPRINT-MASTER-DOC
```

Examples:

- Governance Blueprints
- Collaboration Blueprints
- Security Blueprints
- Compliance Blueprints
- Operational Workflow Blueprints

Generate inside:

```text
02-INSTANCES — Projects\[project_name]\02-BLP
```

---

# BLUEPRINT RULES

Blueprints must:

- follow ARCH rules
- preserve semantic consistency
- preserve naming conventions
- preserve ontology boundaries
- preserve authority hierarchy
- remain operationally realistic
- remain reusable
- remain tenant-scoped

Blueprints must NEVER:

- redefine framework governance
- redefine semantic authority
- generate MTX automatically
- generate AUT automatically
- create deployment logic

Stop after Blueprint generation.

Wait for validation approval.

---

# STEP 5 — VALIDATION PHASE

Execution state required:

```text
READ_ONLY
```

Audit generated Blueprint layer.

Validation targets:

- semantic consistency
- naming consistency
- governance consistency
- operational realism
- authority integrity
- permission logic
- escalation logic
- collaboration logic
- ontology boundaries

Detect:

- naming drift
- authority conflicts
- governance gaps
- unsupported assumptions
- permission conflicts
- semantic contradictions
- operational inconsistencies
- cross-layer contamination

Generate validation report only.

Do NOT auto-correct unless explicitly requested.

---

# STEP 6 — GENERATE MATRIX LAYER

Execution state required:

```text
GENERATE
```

ONLY after Blueprint validation approval.

Generate execution-ready CSV files inside:

```text
02-INSTANCES — Projects\[project_name]\03-MTX — Data Matrices
```

Required files:

- MTX-USERS.csv
- MTX-GROUPS.csv
- MTX-MAILBOXES.csv
- MTX-PERMISSIONS.csv

Optional:

- MTX-LICENSES.csv
- MTX-CHANNELS.csv
- MTX-OWNERSHIP.csv
- MTX-LIFECYCLE.csv

---

# MATRIX RULES

- Use operational roles → convert into operational data
- Generate realistic naming
- Apply naming from ARCH
- Apply governance from BLP
- Apply permissions from BLP
- Apply ownership logic from MASTER

MTX defines operational data only.

MTX must NEVER redefine governance.

No deployment execution yet.

---

# STEP 7 — STOP BEFORE DEPLOYMENT

Execution state required:

```text
PLAN
```

When ready, confirm:

```text
PROJECT READY — BLP and MTX generated
```

Then ask:

```text
Do you want to deploy this project?
```

---

# DEPLOYMENT BEHAVIOR

If user explicitly says YES:

Output ONLY:

```powershell
.\Run-Project.ps1 -ProjectName "[project_name]"
```

DO NOT:

- run scripts
- simulate deployment
- modify tenant
- execute PowerShell
- generate fake execution logs
- auto-connect to Microsoft Graph
- auto-connect to Exchange Online

Deployment execution must remain HUMAN-SUPERVISED.

---

# GLOBAL RULES

- Framework is STRICT READ-ONLY
- Do NOT modify framework files
- Do NOT skip validation phases
- Do NOT skip MTX layer
- Do NOT place tenant Matrix inside framework
- Architecture governs Blueprint
- Blueprint informs Matrix
- Matrix feeds Automation
- Automation must NEVER redefine architecture

Important principle:

```text
redundancy != inconsistency
```

Do NOT simplify intentional governance redundancy.

---

# FINAL OBJECTIVE

```text
Business
→ Operational Blueprint
→ Governance Validation
→ Matrix Generation
→ Deployment Preparation
```

while preserving:

- semantic governance
- ontology integrity
- operational realism
- deterministic consistency
- authority hierarchy
- framework isolation
- controlled execution safety