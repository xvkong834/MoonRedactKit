///|
pub(all) struct Redaction {
  original : SensitiveMatch
  replacement : String
} derive(Eq, Debug)

///|
pub(all) struct RedactResult {
  input_length : Int
  output : String
  redactions : Array[Redaction]
  skipped : Array[SensitiveMatch]
} derive(Eq, Debug)

///|
pub fn redact_text(source : String, policy : RedactPolicy) -> RedactResult {
  redact_matches(source, policy, detect_all(source))
}

///|
pub fn redact_matches(
  source : String,
  policy : RedactPolicy,
  matches : Array[SensitiveMatch],
) -> RedactResult {
  let redactions = []
  let skipped = []
  let buf = StringBuilder()
  let mut cursor = 0
  for item in matches {
    if item.start >= cursor {
      buf.write_string(substring(source, cursor, item.start))
      if policy.accepts(item) {
        let replacement = apply_mask(item, policy.rule_for(item.kind))
        buf.write_string(replacement)
        redactions.push({ original: item, replacement })
      } else {
        buf.write_string(item.text)
        skipped.push(item)
      }
      cursor = item.end
    }
  }
  if cursor < source.length() {
    buf.write_string(substring(source, cursor, source.length()))
  }
  {
    input_length: source.length(),
    output: buf.to_string(),
    redactions,
    skipped,
  }
}

///|
pub fn RedactResult::changed(self : RedactResult) -> Bool {
  self.redactions.length() > 0
}

///|
pub fn RedactResult::redaction_count(self : RedactResult) -> Int {
  self.redactions.length()
}

///|
pub fn RedactResult::risk_score_bp(self : RedactResult) -> Int {
  let mut score = 0
  for redaction in self.redactions {
    score = score + redaction.original.confidence_bp
  }
  clamp_bp(score / max_int(1, self.redactions.length()))
}
