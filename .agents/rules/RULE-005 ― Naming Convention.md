---
trigger: always_on
---

# RULE-005 ― Naming Convention

## Purpose

Use one clear naming system for files, folders, documents, projects, Microsoft 365 objects, scripts, and personal knowledge structures.

This rule applies whenever creating, renaming, organizing, or suggesting names.

---

## Core Principle

Every name must be:

- clear
- sortable
- searchable
- professional
- automation-friendly
- scalable

Avoid random, vague, emotional, or temporary names.

---

## Main Format

Use this structure:

CAT-SUB-001 — Human Readable Name

Example:

ARC-STD-007 — Naming Convention Standard

Meaning:

- Left side = system logic
- Right side = human clarity

---

## Left Side: Technical Code

The left side uses uppercase acronyms.

Format:

CAT-SUB-001

Where:

- CAT = category, area, domain, or project
- SUB = subtype, object type, or function
- 001 = numeric order with zero padding

Examples:

- BLP-TMP-001
- OPS-GRP-001
- ARC-DES-001
- FIN-MBX-001
- PRF-PER-001

---

## Right Side: Human Name

The right side explains the name in normal language.

Format:

CAT-SUB-001 — Human Readable Name

Examples:

- PRF-PER-001 — Personal Finance Rule
- PRF-PRO-001 — Professional Profile Rule
- ARC-STD-007 — Naming Convention Standard
- M365-SPT-001 — SharePoint Structure Guide

---

## Separator Rules

Use hyphen `-` inside the technical code.

Good:

OPS-GRP-001

Bad:

OPS_GRP_001

Use long dash `—` between the technical code and readable title.

Good:

ARC-STD-007 — Naming Convention Standard

Bad:

ARC-STD-007 — Naming Convention Standard

---

## Numbering Rule

Always use 3 digits.

Good:

001
002
010
011

Bad:

1
2
10

This is called zero padding.

Zero padding keeps files visually sorted.

---

## Common Category Prefixes

Use or suggest clear 3–5 letter uppercase prefixes.

Examples:

- GBL = Global
- PRF = Profile
- PER = Personal
- PRO = Professional
- ADM = Administration
- FIN = Finance
- WRK = Work
- HOU = Housing
- SRV = Services
- GOV = Government
- BNK = Banking
- M365 = Microsoft 365
- SPT = SharePoint
- TMS = Teams
- EXC = Exchange
- ARC = Architecture
- TAX = Taxonomy
- NAM = Naming
- DOC = Document
- STR = Strategy
- WFL = Workflow
- RUL = Rule

---

## Common Subtype Prefixes

Use object/function prefixes such as:

- DOC = Generic document
- RUL = Rule
- WFL = Workflow
- IDX = Index
- LOG = Log
- TMP = Reusable template
- MAP = Mapping
- AUD = Audit
- REP = Report
- INV = Invoice
- CTR = Contract
- PAY = Payment
- PS = Payslip
- MBX = Mailbox
- GRP = Group
- USR = User
- SCR = Script

---

## Folder Naming

For simple operational folders, numeric sorting is allowed.

Format:

NN-Name

Examples:

00-INBOX
01-NEW
02-IN PROGRESS
03-WAITING
04-RESOLVED
99-ARCHIVE

Use this when the folder represents a workflow stage.

---

## Documents and Knowledge Files

Use full format:

CAT-SUB-001 — Human Readable Name.md

Examples:

GBL-NAM-001 — Naming Convention Rule.md
PRF-PER-001 — Personal Home Finance Rule.md
PRF-PRO-001 — Professional Profile Rule.md
M365-ARC-001 — Tenant Structure Guide.md

---

## Microsoft 365 Objects

For Microsoft 365 objects, keep names short and system-friendly.

Examples:

OPS-GRP-001
FIN-MBX-002
USR-ADM-001
DEPT-Operations
SUPPORT-Lisa Bennett

Use compact format when the object appears in admin centers, email aliases, scripts, or automation.

---

## Scripts and Code Files

For scripts, prefer lowercase and underscores.

Examples:

create_users.ps1
set_group_permissions.ps1
tenant_sync.ps1
generate_unified_inventory.ps1

Reason:

Scripts should be easy to run, type, and reference in terminal.

---

## Personal File System Usage

When naming local Windows folders or files, prefer:

CAT-SUB-001 — Human Readable Name

Examples:

PER-FIN-001 — Rent Payments
PER-SRV-001 — Total Energies Audit
PER-WRK-001 — Payslip Review
PRO-M365-001 — Microsoft 365 Admin Lab
PRO-AI-001 — AI Agent Research

---

## Bad Examples

Avoid:

john123
teamnew2
final_final
new folder
real version
finance_new_real
test document
random notes
User Test 7

---

## Governance Rules

- One object = one clear purpose
- No duplicates
- No vague names
- No slang
- Prefer English for system names
- Human descriptions can be clearer and longer
- Rename legacy chaos gradually
- Do not over-engineer simple folders
- Keep names short but meaningful

---

## Assistant Behavior

When the user asks for a name:

1. Detect the domain
2. Select a CAT prefix
3. Select a SUB prefix
4. Add zero-padded number
5. Add human readable title
6. Explain briefly why the name fits

When unsure, propose 2–3 naming options.

---

## Final Rule

Always separate:

System logic → Human clarity

Example:

ARC-STD-007 — Naming Convention Standard

This is the preferred naming model.
