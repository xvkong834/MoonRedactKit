///|
pub(all) struct RedactJob {
  id : String
  payload : String
} derive(Eq, Debug)

///|
pub(all) struct RedactJobResult {
  id : String
  result : RedactResult
  gate : GateResult
} derive(Eq, Debug)

///|
pub(all) struct BatchReport {
  jobs : Array[RedactJobResult]
  blocked : Int
  warned : Int
} derive(Eq, Debug)

///|
pub fn RedactJob::new(id : String, payload : String) -> RedactJob {
  { id, payload }
}

///|
pub fn run_batch(
  jobs : Array[RedactJob],
  policy : RedactPolicy,
  gate : LeakGate,
) -> BatchReport {
  let results = []
  let mut blocked = 0
  let mut warned = 0
  for job in jobs {
    let result = redact_text(job.payload, policy)
    let decision = evaluate_gate(gate, result)
    if decision.level == Block {
      blocked = blocked + 1
    } else if decision.level == Warn {
      warned = warned + 1
    }
    results.push({ id: job.id, result, gate: decision })
  }
  { jobs: results, blocked, warned }
}

///|
pub fn BatchReport::passed(self : BatchReport) -> Bool {
  self.blocked == 0
}
