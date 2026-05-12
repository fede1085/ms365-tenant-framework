---
id:
domain:
layer:
type:
status:
depends_on:
feeds:
related_to:
governed_by:
tags:
authority_level:
---

# @SYS-TPL-001 — Metadata Template

> **Purpose:** Reusable metadata YAML template to standardize future documents. Ensure all new files incorporate this YAML frontmatter to support the semantic control layer.

## Usage Instructions
1. Copy the YAML block at the top of this file.
2. Paste it at the very beginning of the new markdown file.
3. Fill in the values using canonical references (e.g., `@ARC-STD-007` for `depends_on`).

## Field Definitions
- **id:** The unique file identifier (e.g., @BLP-TMP-005).
- **domain:** The primary domain (e.g., Identity, Messaging).
- **layer:** The architecture layer (ARC, BLP, MTX, AUT, SYS).
- **type:** The document type (Index, Rule, Template, Matrix, Script).
- **status:** Current state (Draft, Active, Deprecated).
- **depends_on:** List of @ references this file requires to be valid.
- **feeds:** List of @ references that consume this file.
- **related_to:** List of @ references with overlapping context.
- **governed_by:** List of @ references (usually @GOV or @ARC) dictating rules for this file.
- **tags:** Comma-separated list for easy search.
- **authority_level:** The rank in the Authority Map (1-Master, 2-Policy, 3-Structure, 4-Data).
