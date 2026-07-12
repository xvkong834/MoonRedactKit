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
- Chunk-safe streaming redaction for secrets split across log or exporter
  buffers, plus Luhn and Chinese ID-card checksum validation to reduce false
  positives in production telemetry.
- A deterministic 100,000-chunk benchmark for bounded-memory log redaction.
- GitHub Actions CI for `moon check`, `moon test`, `moon fmt`, `moon info`, and
  CLI execution.

## Run the examples

```bash
moon run cmd/main
moon run cmd/bench
moon check --target all
moon fmt --check
moon info && git diff --exit-code -- '*.mbti'
```

The current MoonBit CLI uses `moon fmt --check` as its non-mutating format
gate. It no longer accepts the older `moon fmt --deny-warn` or
`moon info --deny-warn` arguments; CI therefore pairs the supported format
check with `moon info` and a generated-interface diff.

## Compliance

The project is licensed under Apache License 2.0. The root [LICENSE](LICENSE)
file contains the complete license text, [NOTICE](NOTICE) contains the project
notice, and [docs/OPEN_SOURCE_COMPLIANCE.md](docs/OPEN_SOURCE_COMPLIANCE.md)
records the submission review checklist.
