# Acceptance Notes

MoonRedactKit is prepared as a competition project with a concrete reliability
and security use case.

## Implemented scope

- Pure MoonBit sensitive data detectors for email, phone, ID card, bank card,
  token, secret marker, and IP address.
- Redaction policies with per-kind masking behavior and confidence thresholds.
- Batch redaction pipeline for CI and log export workflows.
- Leak gate decisions for blocking or warning on high-risk output.
- Field-path evaluation for structured events.
- JSON export for audit and downstream tooling.
- CLI demo and regression tests.
- GitHub Actions CI with `moon check`, `moon test`, `moon fmt`, `moon info`,
  and CLI execution.

## Review focus

The project is positioned as a privacy and security infrastructure library, not
as a toy masking snippet. The useful boundary is preventing sensitive data from
leaving service logs, CI artifacts, SDK diagnostics, and event streams.

