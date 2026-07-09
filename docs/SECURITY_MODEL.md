# Security Model

MoonRedactKit is a defensive redaction core. It assumes input text may contain
PII or secrets and that downstream systems such as logs, CI artifacts, bug
reports, SDK diagnostics, or public exports are less trusted than the running
process.

## Protected boundary

The library is meant to run before data is emitted. Applications can use it as a
pre-output filter, CI check, snapshot scrubber, or batch audit pass.

## Non-goals

- It is not a cryptographic vault.
- It does not guarantee complete data-loss prevention.
- It does not store sensitive values.
- It does not depend on any platform-specific runtime service.

## Reviewable behavior

Every detection has a kind, detector name, offset range, and confidence score.
Every policy decision can be summarized through JSON and gate results so that
the application can keep privacy decisions auditable.

