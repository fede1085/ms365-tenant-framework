# DSC-AMB-001 — Discovery Notes

## Project Context
* **Company:** AMB Logistics
* **Sector:** International Logistics & Transport
* **Region:** Belgium
* **Target Environment:** Development (DEV)

## Requirements Summary
1. **Infrastructure:**
   - 3 locations: HQ, Warehouse, Dispatch.
   - ~35 realistic fictitious users for full simulation.
2. **Communication:**
   - Standardized shared mailboxes for operational triage.
   - Teams integration for all departments + high-level coordination channels.
3. **Governance:**
   - Strict MFA and Admin role separation.
   - Deterministic naming based on FWK standards.
   - Minimal operational complexity for initial deployment.

## Key Decisions
- Use of "Antwerp HQ" as the primary administrative hub.
- Separation of "Operations Coordination" from general management to facilitate daily workflow sync between Warehouse and Dispatch.
- All users follow the `firstname.lastname` UPN pattern.

## Alignment Note - 2026-05-16
- Teams and SharePoint remain optional workloads, but AMB has explicit blueprint intent for both. Minimal optional MTX files may model them without requiring execution.
- Runtime execution authority is MTX only. Discovery and BLP provide business context and are not runtime inputs.
- Admin and break-glass accounts are protected objects; ObjectId values are unknown until resolved from the live tenant.

---
*Document created during initialization phase.*
