# LAB Hardening Report

## Scope

Controlled runtime hardening was limited to:

- `AMB-Logistics/04-AUT — Automation Executables/01-LAB — Automation Lab/`
- `AMB-Logistics/03-MTX — Data Matrices/`

No canonical, framework, architecture, blueprint, doctrine, discovery, BLP, or other tenant files were intentionally modified.

## Runtime Status

The LAB layer is now a tenant-local controlled runtime:

- Tenant-local controlled runtime
- Production-ready guarded execution
- Protected-object enforced
- No license assignment
- No destructive default behavior
- DryRun first
- Execute requires explicit confirmation

This is production-ready for controlled AMB-Logistics tenant execution. It is not a generic enterprise automation platform.

## Files Updated

- `LAB-Protected-Objects.ps1`
- `LAB-Run-Project.ps1`
- `LAB-Deploy-Tenant.ps1`
- `LAB-Create-Users.ps1`
- `LAB-Create-Groups.ps1`
- `LAB-Create-Mailboxes.ps1`
- `LAB-Apply-Permissions.ps1`
- `LAB-Validation-Report.ps1`
- `LAB-README.md`
- `LAB-HARDENING-REPORT.md`
- `MTX-PROTECTED-OBJECTS.csv`
- `MTX-LICENSES.csv`

## Execution Capabilities

- Users: `New-MgUser` for missing users; `Update-MgUser` for safe field updates only.
- Groups: `New-MgGroup` for missing groups; `Update-MgGroup` for safe metadata updates; `New-MgGroupOwnerByRef` for missing explicit owners.
- Shared mailboxes: `New-Mailbox -Shared` for missing shared mailboxes; bounded propagation polling at 15, 30, and 60 seconds.
- Permissions: `Add-MailboxPermission`, `Add-RecipientPermission`, `Set-Mailbox -GrantSendOnBehalfTo`, `New-MgGroupMemberByRef`, and `New-MgGroupOwnerByRef` for supported add-if-missing operations. Protected principals are skipped.
- Validation: static validation by default; live validation only with `-LiveValidation`.

## Protected Identity Enforcement

The AMB tenant protected identities are:

| DisplayName | UPN | Alias | Role | ObjectId |
| :--- | :--- | :--- | :--- | :--- |
| `Admin Jan` | `admin.jan@amblogistics.be` | `admin.jan` | `Global Administrator` | `UNKNOWN` |
| `Admin Bram` | `admin.bram@amblogistics.be` | `admin.bram` | `IT Administrator / Teams Administrator` | `UNKNOWN` |
| `Emergency BreakGlass` | `breakglass@amblogistics.be` | `breakglass` | `Emergency Access / Global Administrator` | `UNKNOWN` |

Runtime ObjectId protection is supported through:

- `MTX-PROTECTED-OBJECTS.csv`
- `Get-TenantProtectedObjects`
- `-ProtectedGlobalAdminObjectId "<object-id>"` compatibility parameter
- dynamic `Add-LabProtectedObjectId`
- read-only live lookup of AMB protected UPNs before write phases

If the ObjectId remains unresolved, the runtime logs:

```text
Protected ObjectId values unresolved; protection continues by UPN, alias, display name, and role.
```

## Guard Rails

- Protected-object policy loads before any tenant connection.
- Scripts fail closed if `LAB-Protected-Objects.ps1` is missing.
- `Confirm-LabProtectedBaseline` fails if required AMB protected UPNs, aliases, display names, or roles are missing.
- Write operations call `Assert-LabNotProtectedObject` or equivalent target guard before tenant-facing mutation.
- Current connected Graph account is added to runtime mutation protection.
- Non-DryRun execution requires the hard phrase `I UNDERSTAND THIS WILL MODIFY THE TENANT`.
- No licenses are assigned.
- No deletion, wipe, reset, or destructive reconciliation path is implemented by default.
- Teams and SharePoint optional MTX files are modeled but not executed by this LAB runtime.

## Remaining Limitations

- Live validation verifies supported objects and common permission paths; it does not implement a full privileged role audit beyond the protected identity existence/enabled checks.
- SharePoint permission application is not part of this runtime branch.
- SharePoint site URLs use the expected AMB tenant hostname pattern and should be manually confirmed before any future SharePoint execution path is enabled.
- Propagation polling is intentionally bounded and may require a later rerun if Microsoft 365 propagation exceeds the configured waits.
- There is no rollback automation.
- There is no report retention cleanup policy.
