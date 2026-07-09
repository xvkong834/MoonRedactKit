///|
pub fn log_redaction_policy() -> RedactPolicy {
  RedactPolicy::logs()
}

///|
pub fn ci_secret_gate() -> LeakGate {
  LeakGate::new("ci-secret-gate", 0, 20, true)
}

///|
pub fn public_export_gate() -> LeakGate {
  LeakGate::new("public-export", 0, 5, true)
}

///|
pub fn default_event_rules() -> Array[FieldRule] {
  [
    FieldRule::new("user.email", Email, false),
    FieldRule::new("user.phone", Phone, false),
    FieldRule::new("auth.token", Token, true),
    FieldRule::new("payment.card", BankCard, false),
    FieldRule::new("client.ip", IpAddress, false),
  ]
}
