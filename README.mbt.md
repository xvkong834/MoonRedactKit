# MoonRedactKit

MoonRedactKit is a MoonBit foundation library for sensitive data detection,
masking, and redaction audit workflows. It is designed for logging pipelines,
event exporters, CI leak gates, test fixtures, and SDKs that must prevent
accidental exposure of PII or credentials before data leaves a trusted boundary.

The project intentionally does not provide a log collector, storage engine, web
service, or UI dashboard. Its scope is a small, portable decision core:

- detect email, phone, ID card, bank card, token, secret marker, and IP address;
- apply per-kind redaction policy with full mask, edge-preserving mask, hash
  label, drop, pass-through, and confidence threshold;
- produce redaction summaries and gate decisions for CI or release pipelines;
- evaluate configured field paths for event schemas and log envelopes;
- run batch redaction jobs with deterministic summaries;
- export stable JSON for tools that need to review redaction results.

```moonbit nocheck
let result = redact_text(
  "login alice@example.com phone 15507714160 password=verysecretvalue123",
  RedactPolicy::strict(),
)

let gate = evaluate_gate(
  LeakGate::new("ci-log", 0, 10, true),
  result,
)

println(result.output)
println(gate.to_json())
```

## Design boundary

MoonRedactKit is not a general regular expression package, data-loss prevention
platform, or cryptographic vault. The library keeps its core zero-dependency and
backend neutral so it can run in JavaScript, WebAssembly, and native targets.

## Verification

The repository includes CI for Linux, macOS, and Windows. The expected local
checks are:

```bash
moon check --target all
moon test --target all
moon fmt
moon info
moon run cmd/main
```

