///|
pub(all) enum GateLevel {
  Allow
  Warn
  Block
} derive(Eq, Debug)

///|
pub fn GateLevel::name(self : GateLevel) -> String {
  match self {
    Allow => "allow"
    Warn => "warn"
    Block => "block"
  }
}

///|
pub(all) struct LeakGate {
  name : String
  max_high_risk : Int
  max_total : Int
  block_secrets : Bool
} derive(Eq, Debug)

///|
pub(all) struct GateResult {
  gate : String
  level : GateLevel
  reason : String
  total : Int
  high_risk : Int
} derive(Eq, Debug)

///|
pub fn LeakGate::new(
  name : String,
  max_high_risk : Int,
  max_total : Int,
  block_secrets : Bool,
) -> LeakGate {
  {
    name,
    max_high_risk: max_int(0, max_high_risk),
    max_total: max_int(0, max_total),
    block_secrets,
  }
}

///|
pub fn evaluate_gate(gate : LeakGate, result : RedactResult) -> GateResult {
  let summary = result.summary()
  let high_risk = summary.id_card +
    summary.bank_card +
    summary.token +
    summary.secret
  if gate.block_secrets && summary.secret > 0 {
    {
      gate: gate.name,
      level: Block,
      reason: "secret_detected",
      total: summary.total,
      high_risk,
    }
  } else if high_risk > gate.max_high_risk {
    {
      gate: gate.name,
      level: Block,
      reason: "high_risk_limit_exceeded",
      total: summary.total,
      high_risk,
    }
  } else if summary.total > gate.max_total {
    {
      gate: gate.name,
      level: Warn,
      reason: "total_limit_exceeded",
      total: summary.total,
      high_risk,
    }
  } else {
    {
      gate: gate.name,
      level: Allow,
      reason: "within_policy",
      total: summary.total,
      high_risk,
    }
  }
}

///|
pub fn GateResult::allowed(self : GateResult) -> Bool {
  self.level != Block
}
