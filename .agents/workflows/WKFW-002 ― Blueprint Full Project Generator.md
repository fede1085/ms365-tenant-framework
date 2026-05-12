---
description: Generates project-specific Microsoft 365 tenant blueprint documents from PRJ-BLUEPRINT-MASTER-DOC.md and the CORE framework templates.
---

# WKFW-002 — Microsoft 365 Tenant Automation Blueprint

## Execution Model Awareness

This workflow operates under the following model:

ARCH → defines rules  
BLP → defines structure  
MTX → defines real data  
AUT → executes data  

The agent MUST respect this separation.

## Execution State Gate (Mandatory)

Allowed operational states:
- `READ_ONLY` → inspect and validate only; no file generation, no file writes.
- `PLAN` → propose structure and implementation plan; no file writes.
- `GENERATE` → create/update blueprint and matrix artifacts only when explicitly requested.
- `EXECUTE` → never performed by this workflow; execution is delegated to AUT scripts.

Default state is `READ_ONLY` unless the user explicitly authorizes a higher state.
If the task is audit, inspection, or semantic validation, state MUST remain `READ_ONLY`.

---

## Phase Control

Phase 1 → Architecture Alignment  
- Validate inputs against naming, security, and structure rules  

Phase 2 → Blueprint Generation  
- Generate ONLY template structures  
- Use placeholders (ROLE-XXX, <domain>)  
- DO NOT generate real users or emails  

Phase 3 → Matrix Generation (IMPORTANT)  
- Convert Blueprint structures into real instance data
- Generate CSV files
- Use consistent naming and IDs
- Prepare data for automation scripts

Phase 4 → Execution (external)  
- Execution is handled only by Automation layer using MTX  

---

## Matrix Output Location

Matrix files MUST be created in:
`02-INSTANCES — Projects/<PROJECT_NAME>/03-MTX — Data Matrices/`

Example:
`02-INSTANCES — Projects/VAN-Aerde-Logistics/03-MTX — Data Matrices/`

## Files to Generate

### Users
`MTX-USERS.csv`
Columns: `UserID,DisplayName,UPN,Role,Department,License`

### Groups
`MTX-GROUPS.csv`
Columns: `GroupName,Alias,Type,Department`

### Mailboxes
`MTX-MAILBOXES.csv`
Columns: `Mailbox,Type,Department`

### Permissions
`MTX-PERMISSIONS.csv`
Columns: `Mailbox,FullAccess,SendAs,Owner`

## Matrix Data Rules
- Use sequential IDs: U001, U002, U003
- Map roles from Blueprint
- Convert ROLE → actual instance rows
- Replace placeholders with realistic example data
  Example: `ROLE-OPS-LEAD` → `ops.lead@<domain>`

## Security Enforcement
- admin mailboxes → NO SendAs
- Only customer-facing mailboxes → SendAs allowed
- Protected users must not be assigned automatically

## DO NOT EXECUTE ANYTHING
IMPORTANT:
- Do NOT run scripts
- Do NOT simulate execution
- Only generate data files

---

## Purpose

Guiar la creación interactiva y estructurada de un tenant Microsoft 365 para SMEs.

Convierte:
negocio → arquitectura → datos → automatización

Capas:
- Identity
- Collaboration
- Service (Exchange)
- Governance
- Automation

---

## Trigger Usage

- Inicia nuevo tenant
- Crear blueprint empresa [sector]
- Ejecuta WKF-TENANT-001

---

# WORKFLOW PHASES

---

## Fase 0 — Business Discovery (Nivel 0)

Objetivo: entender la empresa

Preguntas:
- Nombre empresa
- Sector
- Tamaño
- Ubicaciones
- Licencias

---

## Fase 1 — Identity Layer (Nivel 1)

Objetivo: definir quién existe

Definir:
- usuarios
- roles
- managers

Preguntas:
- Departamentos
- Líderes
- ¿Usuarios ficticios?

---

## Fase 2 — Collaboration Layer (Nivel 2 parcial)

Objetivo: trabajo interno

Definir:
- Groups
- Teams
- Memberships

Preguntas:
- ¿Team por departamento?
- ¿Grupos globales?

---

## Fase 3 — Service Layer (Exchange) (Nivel 2 completo)

Objetivo: comunicación operativa

Definir:
- shared mailboxes
- flujos de trabajo

Ejemplos:
operations@<domain>
support@<domain>
sales@<domain>
finance@<domain>
hr@<domain>
it@<domain>
admin@<domain>

Preguntas:
- ¿Qué buzones?
- ¿Qué tipo de flujo?

---

## Fase 4 — Governance Layer (Nivel 3)

Objetivo: orden y control

Aplicar:
- naming
- ownership
- permissions

Reglas:

Naming:
PREFIX-Name
function@<domain>
DEPT-Name

Permisos:
- FullAccess
- SendAs
- Owner

Validar:
- cada mailbox tiene owner
- naming consistente
- no duplicados

---

## Fase 5 — Automation Preparation (Nivel 4)

Objetivo: preparar despliegue

Generar:
- Department Matrix
- User Matrix
- Group Matrix
- Mailbox Matrix
- Permission Matrix

CSV requeridos:

users.csv
groups.csv
mailboxes.csv
permissions.csv
licenses.csv

---

## Fase 6 — Security & Maturity (Nivel 5)

No ejecutar en este workflow

Incluye:
- MFA
- Conditional Access
- Intune
- Compliance

---

# CORE LOGIC

Separación de capas:

Users → Identity
Groups → Collaboration
Mailboxes → Service
Permissions → Governance
Scripts → Automation

---

# INTERACTIVE FLOW

Orden:

1. Empresa
2. Departamentos
3. Usuarios
4. Grupos
5. Mailboxes
6. Seguridad

---

# OUTPUTS

## Blueprint Master Document

Nombre obligatorio:
PRJ-BLUEPRINT-MASTER-DOC.md

Contenido:
- Company overview
- Departments
- Users
- Groups
- Mailboxes
- Operational logic
- Governance decisions

---

## Matrices

- Departments
- Users
- Groups
- Mailboxes
- Permissions

---

## CSV Schemas

users.csv
groups.csv
mailboxes.csv
permissions.csv
licenses.csv

---

## Resultado final

Un único documento consolidado.

---

## Validation Step

- Validate naming against Naming Convention Rule
- Validate permissions against Security Baseline
- Validate structure against Architecture layer

If validation fails → STOP and ask user for correction.

---

# VALIDATION

- Prefijos correctos
- Naming consistente
- Mailboxes con owner
- Sin duplicados
- Capas respetadas

---

# RESPONSE STYLE

- Claro
- Estructurado
- Ejecutable
- Realista

---

# PRINCIPIO FINAL

El tenant representa la empresa.

No es técnico.

Es operativo.

---

# NOTA

Este workflow:
genera blueprint

El siguiente:
genera scripts
(Defined in Blueprint / to be implemented in Matrix)

---

## Rules Alignment

- RULE-001 ― Framework Interpretation Model.md
- RULE-003 ― Execution Model.md
- RULE-004 ― Security Baseline.md
- RULE-005 ― Naming Convention.md

---

## Final Output

The agent produces:

1. Blueprint documents (BLP)
2. Matrix files (MTX) in CSV format

These files are ready for execution by Automation scripts.

---

## FINAL STEP — Deployment

When all Blueprint and Matrix files are generated:

1. Ask user:

"Do you want to deploy this project to a real tenant?"

2. If YES:

Ask:
"Which project do you want to deploy?"

3. Then output ONLY:

Run:
.\Run-Project.ps1 -ProjectName "<PROJECT_NAME>"

4. DO NOT execute anything
5. DO NOT simulate deployment
6. STOP after providing command
