# Acceptance Notes

MoonRedactKit is prepared as a competition project with a concrete reliability
and security use case.

## Implemented scope

- Pure MoonBit sensitive data detectors for email, phone, ID card, bank card,
  token, secret marker, and IP address.
- IPv4 detection validates octets and rejects impossible addresses such as
  `999.1.1.1`, reducing noisy log findings.
- Redaction policies with per-kind masking behavior and confidence thresholds.
- Batch redaction pipeline for CI and log export workflows.
- Leak gate decisions for blocking or warning on high-risk output.
- Field-path evaluation for structured events.
- JSON export for audit and downstream tooling.
- Chunk-safe streaming redaction that preserves an unfinished log field across
  buffer boundaries, preventing a split secret from escaping in a prefix.
- Luhn bank-card and Chinese resident-ID checksum validation to reduce false
  positives from numeric telemetry.
- Deterministic 100,000-chunk benchmark in `cmd/bench`.
- CLI demo and regression tests.
- GitHub Actions CI with `moon check`, `moon test`, `moon fmt`, `moon info`,
  and CLI execution.
- Complete project-level Apache License 2.0 text in `LICENSE`, project notice
  in `NOTICE`, package license metadata in `moon.mod`, and review notes in
  `docs/OPEN_SOURCE_COMPLIANCE.md`.

## Review focus

The project is positioned as a privacy and security infrastructure library, not
as a toy masking snippet. The useful boundary is preventing sensitive data from
leaving service logs, CI artifacts, SDK diagnostics, and event streams.

## Submission checklist

- `LICENSE` is the full Apache License 2.0 text, not a short declaration.
- `NOTICE` and `moon.mod` agree with the declared license.
- CI includes formatting, metadata generation, checks, tests, and CLI smoke run.
- CI listens to the GitLink default branch (`master`) as well as `main`, and
  uses the current non-mutating `moon fmt --check` format gate.
- Tests cover positive and negative detector behavior, policy behavior, leak
  gates, field rules, batch reports, JSON export, and audit explanations.
