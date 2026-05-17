# MTX Data Matrices

This layer contains lightweight sample/reference matrices for reusable tenant modeling.

These files are not tenant runtime truth. Active tenant runtime MTX belongs under:

```text
02-INSTANCES — Projects/<Tenant>/03-MTX — Data Matrices/
```

Purpose:

- show expected runtime MTX column shapes
- provide small SME-scale examples
- demonstrate relationships between identity, collaboration, and security data
- support future generation, validation, discovery, and remediation work

AUT executes runtime-normalized MTX only. BLP may guide MTX generation, but BLP is not runtime input.

## Folders

```text
Identity/
Collaboration/
Security/
```

## Scope

These are reference examples only. They do not add runtime behavior, provisioning logic, license assignment, security engines, or tenant-specific data.
