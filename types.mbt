///|
pub(all) enum SensitiveKind {
  Email
  Phone
  IdCard
  BankCard
  Token
  Secret
  IpAddress
  Custom
} derive(Eq, Debug)

///|
pub fn SensitiveKind::name(self : SensitiveKind) -> String {
  match self {
    Email => "email"
    Phone => "phone"
    IdCard => "id_card"
    BankCard => "bank_card"
    Token => "token"
    Secret => "secret"
    IpAddress => "ip_address"
    Custom => "custom"
  }
}

///|
pub(all) enum MaskMode {
  Full
  KeepPrefixSuffix
  HashLabel
  Drop
  Pass
} derive(Eq, Debug)

///|
pub fn MaskMode::name(self : MaskMode) -> String {
  match self {
    Full => "full"
    KeepPrefixSuffix => "keep_prefix_suffix"
    HashLabel => "hash_label"
    Drop => "drop"
    Pass => "pass"
  }
}

///|
pub(all) struct SensitiveMatch {
  kind : SensitiveKind
  start : Int
  end : Int
  text : String
  confidence_bp : Int
  detector : String
} derive(Eq, Debug)

///|
pub fn SensitiveMatch::new(
  kind : SensitiveKind,
  start : Int,
  end : Int,
  text : String,
  confidence_bp : Int,
  detector : String,
) -> SensitiveMatch {
  { kind, start, end, text, confidence_bp: clamp_bp(confidence_bp), detector }
}

///|
pub fn SensitiveMatch::length(self : SensitiveMatch) -> Int {
  self.end - self.start
}

///|
pub fn clamp_bp(value : Int) -> Int {
  if value < 0 {
    0
  } else if value > 10000 {
    10000
  } else {
    value
  }
}

///|
pub fn min_int(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn max_int(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}
