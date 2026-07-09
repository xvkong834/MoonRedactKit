///|
pub(all) struct RedactSummary {
  total : Int
  email : Int
  phone : Int
  id_card : Int
  bank_card : Int
  token : Int
  secret : Int
  ip_address : Int
  custom : Int
} derive(Eq, Debug)

///|
pub fn summarize_matches(matches : Array[SensitiveMatch]) -> RedactSummary {
  let mut email = 0
  let mut phone = 0
  let mut id_card = 0
  let mut bank_card = 0
  let mut token = 0
  let mut secret = 0
  let mut ip_address = 0
  let mut custom = 0
  for item in matches {
    match item.kind {
      Email => email = email + 1
      Phone => phone = phone + 1
      IdCard => id_card = id_card + 1
      BankCard => bank_card = bank_card + 1
      Token => token = token + 1
      Secret => secret = secret + 1
      IpAddress => ip_address = ip_address + 1
      Custom => custom = custom + 1
    }
  }
  {
    total: matches.length(),
    email,
    phone,
    id_card,
    bank_card,
    token,
    secret,
    ip_address,
    custom,
  }
}

///|
pub fn RedactResult::summary(self : RedactResult) -> RedactSummary {
  let matches = []
  for redaction in self.redactions {
    matches.push(redaction.original)
  }
  summarize_matches(matches)
}

///|
pub fn RedactSummary::has_high_risk(self : RedactSummary) -> Bool {
  self.id_card > 0 || self.bank_card > 0 || self.secret > 0 || self.token > 0
}
