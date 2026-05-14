# AUT-SYS-001 — Execution State Model

## Reusable Tenant Automation Layer

This document defines AUT runtime object states. Orchestration modes such as READ_ONLY, PLAN, GENERATE, and EXECUTE are defined by the execution workflow.

---

# 1. Purpose

Define the runtime execution states used by the Automation layer.

This document controls how AUT tracks object execution during tenant deployment.

It prevents ambiguous automation behavior when scripts create, skip, retry, wait, fail, or validate tenant objects.

---

# 2. Layer Declaration

- PRIMARY LAYER: LAYER 4 — Tenant Operational Execution
- ONTOLOGY OWNER: AUT
- SCOPE: Runtime execution behavior
- SOURCE INPUT: MTX
- EXECUTION OUTPUT: Tenant operational state

AUT consumes validated MTX data only.

AUT must never redefine ARCH, BLP, SYS, or CAN governance.

---

# 3. Core Principle

Automation is not a single action.

Automation is a controlled state transition.

Each object processed by AUT must have a clear execution state.

---

# 4. Runtime State Model

Allowed runtime states:

- PENDING
- VALIDATING
- READY
- CREATING
- UPDATING
- SKIPPED
- SKIPPED_PROTECTED
- WAITING_PROPAGATION
- VALIDATING_RESULT
- COMPLETED
- WARNING
- FAILED
- BLOCKED
- ROLLBACK_REQUIRED

---

# 5. State Definitions

## PENDING

Object is loaded from MTX but not processed yet.

Example:

User exists in MTX-USERS.csv but no validation has started.

---

## VALIDATING

Object data is being checked before execution.

Checks may include:

- required fields
- naming format
- duplicate detection
- dependency presence
- protected object rules

---

## READY

Object passed validation and can be processed.

READY does not mean executed.

---

## CREATING

AUT is creating a new tenant object.

Example:

- user
- group
- shared mailbox
- permission assignment

---

## UPDATING

AUT is updating an existing tenant object.

Use only when update behavior is explicitly allowed.

Do not update protected objects automatically.

---

## SKIPPED

Object already exists or is intentionally excluded.

SKIPPED is acceptable only when the existing object matches expected MTX intent.

---

## SKIPPED_PROTECTED

The object matched protected-object rules and was intentionally not modified.

SKIPPED_PROTECTED is a safe terminal state.

It applies when an object is protected and no mutation is allowed.

It must not be treated as FAILED.

It must remain distinguishable from normal SKIPPED.

SKIPPED_PROTECTED must be logged with the protected-object reason.

---

## WAITING_PROPAGATION

Object was created or updated, but Microsoft 365 has not fully exposed it yet.

Common cases:

- Exchange shared mailbox creation
- group visibility
- license assignment delay
- mailbox permission availability

---

## VALIDATING_RESULT

AUT is checking whether the tenant state now matches MTX intent.

Script completion alone is not success.

Tenant reality must be verified.

---

## COMPLETED

Object is verified and matches expected MTX state.

---

## WARNING

Object was processed, but a non-blocking issue remains.

Example:

- optional field missing
- delayed property not yet visible
- license assignment pending

---

## FAILED

Execution failed and cannot safely continue for that object.

FAILED must produce a clear error message.

---

## BLOCKED

Object cannot be processed because a dependency is missing or invalid.

Examples:

- user missing for permission assignment
- group owner missing
- mailbox not available
- license SKU unavailable

---

## ROLLBACK_REQUIRED

Execution changed tenant state but did not complete safely.

Manual review is required before continuing.

AUT must not auto-delete resources unless explicit deletion behavior exists.

---

# 6. Required State Transition

Default transition:

PENDING
→ VALIDATING
→ READY
→ CREATING or UPDATING or SKIPPED or SKIPPED_PROTECTED
→ WAITING_PROPAGATION if needed
→ VALIDATING_RESULT
→ COMPLETED or WARNING or FAILED

Blocked transition:

PENDING
→ VALIDATING
→ BLOCKED

Protected transition:

PENDING
→ VALIDATING
→ SKIPPED_PROTECTED or BLOCKED

SKIPPED_PROTECTED is terminal unless a separately documented emergency override workflow exists.

Failure transition:

CREATING or UPDATING
→ FAILED

Unsafe partial execution:

CREATING or UPDATING
→ ROLLBACK_REQUIRED

---

# 7. Object Scope

This state model applies to:

- users
- groups
- Teams-related groups
- shared mailboxes
- mailbox permissions
- group memberships
- license assignments
- aliases
- validation reports

---

# 8. Execution Rules

AUT must:

- load MTX data first
- validate MTX data before execution
- process dependencies in order
- track object state
- verify result after execution
- log failures clearly
- stop on critical tenant-targeting errors

AUT must not:

- consume BLP as execution data
- redesign the tenant
- modify framework files
- auto-delete by default
- hide failed state
- treat script completion as deployment success

---

# 9. Dependency Order

Recommended execution order:

1. Validate MTX files
2. Connect to target tenant
3. Verify tenant targeting
4. Create or verify users
5. Assign or verify licenses
6. Create or verify groups
7. Add or verify memberships
8. Create or verify shared mailboxes
9. Wait for propagation where required
10. Apply or verify permissions
11. Generate validation report

---

# 10. Critical Stop Conditions

AUT must STOP if:

- target tenant cannot be verified
- required MTX file is missing
- required MTX column is missing
- protected object rule is violated
- TenantId or TenantDomain mismatch is detected
- execution state is unclear
- CRITICAL validation issue remains unresolved

---

# 11. Logging Requirement

Each object should log:

- ObjectType
- ObjectId or ObjectName
- Source MTX file
- PreviousState
- CurrentState
- ActionTaken
- Result
- ErrorMessage
- Timestamp

Minimum log example:

ObjectType: User
ObjectName: jan.operations@domain
Source: MTX-USERS.csv
PreviousState: READY
CurrentState: COMPLETED
ActionTaken: Created user
Result: Success

---

# 12. Dry-Run Behavior

In dry-run mode:

- no tenant changes are made
- states may be simulated up to READY
- planned actions must be displayed
- no object should enter CREATING or UPDATING

Dry-run output must clearly say:

No changes were applied.

---

# 13. Human Supervision Rule

AUT execution remains human-supervised.

The orchestration mode must never move into EXECUTE automatically.

Execution requires explicit approval and tenant confirmation.

---

# 14. Final Principle

MTX defines desired tenant state.

AUT moves tenant reality toward MTX state.

AUT must do this through explicit, logged, validated state transitions.
