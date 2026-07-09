///|
pub(all) struct FieldValue {
  path : String
  value : String
} derive(Eq, Debug)

///|
pub(all) struct FieldRule {
  path : String
  kind : SensitiveKind
  required : Bool
} derive(Eq, Debug)

///|
pub(all) struct FieldFinding {
  path : String
  kind : SensitiveKind
  present : Bool
  redacted : Bool
} derive(Eq, Debug)

///|
pub fn FieldValue::new(path : String, value : String) -> FieldValue {
  { path, value }
}

///|
pub fn FieldRule::new(
  path : String,
  kind : SensitiveKind,
  required : Bool,
) -> FieldRule {
  { path, kind, required }
}

///|
pub fn evaluate_fields(
  fields : Array[FieldValue],
  rules : Array[FieldRule],
  policy : RedactPolicy,
) -> Array[FieldFinding] {
  let findings = []
  for rule in rules {
    let mut found = false
    let mut redacted = false
    for field in fields {
      if field.path == rule.path {
        found = true
        let result = redact_text(field.value, policy)
        redacted = redacted || result.changed()
      }
    }
    findings.push({ path: rule.path, kind: rule.kind, present: found, redacted })
  }
  findings
}

///|
pub fn missing_required_fields(findings : Array[FieldFinding]) -> Int {
  let mut count = 0
  for item in findings {
    if !item.present {
      count = count + 1
    }
  }
  count
}
