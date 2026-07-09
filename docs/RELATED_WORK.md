# Related Work

## Mooncakes scan

Before choosing this topic, we checked MoonBit community packages around
schema validation and logging. Existing packages cover JSON Schema validation,
Zod-like runtime schema checks, generic code generation, structured logging, and
tracing. MoonRedactKit targets a different layer: pre-export sensitive data
detection, policy-based masking, and CI/audit gate decisions.

## Difference from logging libraries

Structured logging libraries decide how events are emitted. MoonRedactKit
decides whether event content is safe enough to emit and how sensitive values
should be transformed. It can be embedded before any logger, telemetry exporter,
CLI output, or test snapshot writer.

## Difference from regex helpers

MoonRedactKit is not a general regex wrapper. It provides stable domain-level
types such as `SensitiveKind`, `RedactPolicy`, `LeakGate`, and `BatchReport`, so
applications can keep privacy decisions auditable rather than scattering ad-hoc
string replacements.

