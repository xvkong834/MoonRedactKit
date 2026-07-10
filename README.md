# MoonRedactKit

MoonRedactKit is a MoonBit foundation library for sensitive data detection,
redaction policy, and audit gate primitives. It targets log pipelines, CI leak
checks, SDK diagnostics, event exporters, and test fixtures that must prevent
PII or credentials from leaving a trusted boundary.

See [README.mbt.md](README.mbt.md) for the package-facing documentation.

## What is included

- Pure MoonBit detectors for email, phone, ID card, bank card, token, secret
  marker, and validated IPv4 address patterns.
- Configurable redaction policies with full masking, edge-preserving masking,
  hash labels, drop, pass-through, and confidence thresholds.
- Leak gates, batch reports, field-path evaluation, JSON export, CLI demo, and
  regression tests.
- GitHub Actions CI for `moon check`, `moon test`, `moon fmt`, `moon info`, and
  CLI execution.

## Compliance

The project is licensed under Apache License 2.0. The root [LICENSE](LICENSE)
file contains the complete license text, [NOTICE](NOTICE) contains the project
notice, and [docs/OPEN_SOURCE_COMPLIANCE.md](docs/OPEN_SOURCE_COMPLIANCE.md)
records the submission review checklist.
