---
description: Interactive Microsoft 365 tenant blueprint workflow. Converts business requirements into deployable architecture, governance standards, user/group/mailbox matrices, CSV schemas, and automation-ready project assets step by step.
---

Microsoft 365 Tenant Automation Blueprint

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
- `PLAN` → propose structure and next actions; no file writes.
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

# Purpose
Guiar al usuario en la creación interactiva de arquitecturas de Microsoft 365 para nuevas empresas (SMEs). Transforma la visión de negocio en matrices de datos (usuarios, grupos, mailboxes) y estándares de gobernanza listos para ser desplegados mediante scripts.

# Trigger Usage
- "Antigravity, inicia un nuevo proyecto de tenant"
- "Quiero crear el blueprint para una empresa de [Sector]"
- "Ejecuta el workflow WKF-TENANT-001"

# Interactive Phases

## Fase 1 — Descubrimiento de Negocio (Nivel 0)
El objetivo es entender el modelo de negocio y el alcance.
**Preguntas clave:**
1. **Nombre de la Compañía:** ¿Cuál es el nombre legal/comercial?
2. **Sector / Business Type:** ¿A qué se dedica? (ej. Logística, Retail, Clínica, Consultora)
3. **Tamaño:** ¿Cuántos empleados iniciales estimamos?
4. **Ubicaciones:** ¿Es una oficina única o multisede?
5. **Licenciamiento:** ¿Qué tipo de licencias M365 se planean usar? (ej. Business Standard, Premium, E3, E5)

## Fase 2 — Arquitectura de Identidad y Colaboración (Nivel 1-2)
Definición de las capas de identidad y trabajo en equipo.
**Preguntas clave:**
1. **Departamentos:** ¿Cuáles son las áreas clave? (Sugerir: Operations, Support, Sales, Finance, HR, IT, Admin)
2. **Matriz de Usuarios:** ¿Quiénes son los líderes de departamento? ¿Necesitas generar usuarios ficticios realistas?
3. **Estructura de Grupos:** ¿Cada departamento necesita un Microsoft Team? ¿Habrá grupos transversales (ej. Leadership, All-Staff)?
4. **Shared Mailboxes:** ¿Qué buzones operativos se necesitan? (ej. info@, ventas@, soporte@)

## Fase 3 — Gobernanza y Naming (Nivel 3)
Aplicación del estándar de orden y control.
**Lógica a aplicar:**
- **User Role / Placeholder:** `ROLE-XXX` (ej: `ROLE-OPS-LEAD`)
- **Shared Mailboxes:** `funcion@<domain>` (sin palabras como "shared" o "buzon")
- **Departamentos:** `DEPT-Nombre`
- **Grupos:** `Nombre Team` para colaboración, `Nombre Group` para seguridad/otros.
- **Taxonomía:** `NN-NOMBRE` para carpetas y `CAT-VALOR` para etiquetas.

## Fase 4 — Preparación para Automatización (Nivel 4)
Generación de los archivos fuente para el despliegue.
**Acciones:**
1. Generar `BLP-TMP-002 — Department Matrix Template`.
2. Generar `BLP-TMP-003 — User Matrix Template`.
3. Generar `BLP-TMP-005 — Shared Mailbox Matrix Template`.
4. Generar esquemas CSV (`users.csv`, `mailboxes.csv`).

# Questions to Ask
*Presentar de forma secuencial según la fase:*
1. "¿Cuál es el nombre de la empresa y su sector principal?"
2. "¿Qué departamentos quieres activar? ¿Quieres que sugiera una estructura basada en el sector?"
3. "¿Quieres que genere una lista de usuarios realistas con sus roles?"
4. "¿Qué nivel de seguridad prefieres? (Básico, Estándar, Alta Seguridad)"

# Outputs to Generate
1. **Blueprint Document:** Un archivo `.md` con la arquitectura completa (capas Identity, Collaboration, Service, Governance).
2. **Matrices de Datos:** Tablas en Markdown para departamentos, usuarios y grupos.
3. **Naming Standard Document:** Use the following name `PRJ-BLUEPRINT-MASTER-DOC.md` for the ne blueprint document.
4. **CSV Schemas:** Bloques de código con el formato necesario para scripts de PowerShell.
5. **Final Output:** Generate a single consolidated blueprint document with the following:

    Rules:
        - ALWAYS use this exact filename
        - DO NOT create variations
        - DO NOT include project name in filename
        - This file acts as the single source of truth for Workflow 002

    Content must include:
        - Company overview
        - Departments
        - Users and roles
        - Business structure
        - Operational logic
        - Any decisions made during the interactive phases

This file will be used as the ONLY input for the automation/generation workflow.

---

## Validation Step

- Validate naming against Naming Convention Rule
- Validate permissions against Security Baseline
- Validate structure against Architecture layer

If validation fails → STOP and ask user for correction.

---

# Validation Checks
- [ ] ¿Todos los objetos tienen un prefijo válido según el diccionario?
- [ ] ¿Cada Shared Mailbox tiene al menos un Owner definido?
- [ ] ¿Se respeta la jerarquía de niveles (0 al 5)?
- [ ] ¿Los usernames son consistentes (`nombre.departamento@`)?
- [ ] ¿Se evita el uso de caracteres especiales y nombres genéricos?

# Response Style
- **Tono:** Profesional, arquitectónico, ejecutivo.
- **Idioma:** Español por defecto (según GEMINI.md).
- **Formato:** Listas estructuradas, tablas claras y bloques de código listos para copiar.
- **Acción:** No solo sugiere, sino que propone estructuras concretas basadas en las respuestas del usuario.

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

---

### !Important:
**Framework examples are conceptual references only.**

The agent must avoid assuming operational structures and real data from examples like Blueprints (BLP-...) and Architecture (ARCH-...) files and must derive the final tenant structure from the interactive project discovery process.

These files are ready for execution by Automation scripts.

---

### !Important: 
**Framework interpretation rules and behavior are defined in file: @RULE-001 ― Framework Interpretation Model.md**

**TL;DR**
The agent must differentiate:
- conceptual framework layers (ARC / BLP)
- reusable implementation patterns
- deployable project data (MTX)

Final tenant structure created for an specific instance of a specific project must always be derived from the interactive discovery process stated in the file @00-START — Initialization Prompt.md
