///|
fn escape_json(value : String) -> String {
  let buf = StringBuilder()
  for i = 0; i < value.length(); i = i + 1 {
    match value.get_char(i) {
      Some('\\') => buf.write_string("\\\\")
      Some('"') => buf.write_string("\\\"")
      Some('\n') => buf.write_string("\\n")
      Some('\r') => buf.write_string("\\r")
      Some('\t') => buf.write_string("\\t")
      Some(ch) => buf.write_char(ch)
      None => ()
    }
  }
  buf.to_string()
}

///|
pub fn SensitiveMatch::to_json(self : SensitiveMatch) -> String {
  "{\"kind\":\"\{self.kind.name()}\",\"start\":\{self.start},\"end\":\{self.end},\"confidence_bp\":\{self.confidence_bp},\"detector\":\"\{escape_json(self.detector)}\"}"
}

///|
pub fn RedactSummary::to_json(self : RedactSummary) -> String {
  "{\"total\":\{self.total},\"email\":\{self.email},\"phone\":\{self.phone},\"id_card\":\{self.id_card},\"bank_card\":\{self.bank_card},\"token\":\{self.token},\"secret\":\{self.secret},\"ip_address\":\{self.ip_address},\"custom\":\{self.custom}}"
}

///|
pub fn GateResult::to_json(self : GateResult) -> String {
  "{\"gate\":\"\{escape_json(self.gate)}\",\"level\":\"\{self.level.name()}\",\"reason\":\"\{escape_json(self.reason)}\",\"total\":\{self.total},\"high_risk\":\{self.high_risk}}"
}

///|
pub fn RedactResult::to_json(self : RedactResult) -> String {
  "{\"input_length\":\{self.input_length},\"output\":\"\{escape_json(self.output)}\",\"redactions\":\{self.redactions.length()},\"summary\":\{self.summary().to_json()}}"
}

///|
pub fn BatchReport::to_json(self : BatchReport) -> String {
  "{\"jobs\":\{self.jobs.length()},\"blocked\":\{self.blocked},\"warned\":\{self.warned},\"passed\":\{self.passed()}}"
}
