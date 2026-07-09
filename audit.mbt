///|
pub(all) struct AuditLine {
  code : String
  message : String
} derive(Eq, Debug)

///|
pub fn AuditLine::new(code : String, message : String) -> AuditLine {
  { code, message }
}

///|
pub fn explain_gate(result : GateResult) -> AuditLine {
  match result.level {
    Allow => AuditLine::new("allow", "output is within redaction policy")
    Warn =>
      AuditLine::new(
        "warn", "output contains more sensitive fields than expected",
      )
    Block => AuditLine::new("block", "output contains high-risk sensitive data")
  }
}

///|
pub fn explain_result(result : RedactResult) -> Array[AuditLine] {
  let lines = []
  let summary = result.summary()
  if summary.total == 0 {
    lines.push(AuditLine::new("clean", "no sensitive data detected"))
  } else {
    lines.push(
      AuditLine::new("redacted", "\{summary.total} sensitive value(s) redacted"),
    )
  }
  if summary.has_high_risk() {
    lines.push(
      AuditLine::new(
        "high-risk", "credential, identity, or payment data detected",
      ),
    )
  }
  lines
}

///|
pub fn AuditLine::to_json(self : AuditLine) -> String {
  "{\"code\":\"\{self.code}\",\"message\":\"\{self.message}\"}"
}
