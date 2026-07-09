///|
pub(all) struct RedactRule {
  kind : SensitiveKind
  mode : MaskMode
  keep_prefix : Int
  keep_suffix : Int
  replacement : String
} derive(Eq, Debug)

///|
pub fn RedactRule::new(
  kind : SensitiveKind,
  mode : MaskMode,
  keep_prefix : Int,
  keep_suffix : Int,
  replacement : String,
) -> RedactRule {
  {
    kind,
    mode,
    keep_prefix: max_int(0, keep_prefix),
    keep_suffix: max_int(0, keep_suffix),
    replacement,
  }
}

///|
pub(all) struct RedactPolicy {
  name : String
  default_mode : MaskMode
  rules : Array[RedactRule]
  min_confidence_bp : Int
  fail_closed : Bool
} derive(Eq, Debug)

///|
pub fn RedactPolicy::new(name : String) -> RedactPolicy {
  {
    name,
    default_mode: KeepPrefixSuffix,
    rules: [],
    min_confidence_bp: 6500,
    fail_closed: true,
  }
}

///|
pub fn RedactPolicy::strict() -> RedactPolicy {
  let policy = RedactPolicy::new("strict")
  policy.rules.push(RedactRule::new(Email, KeepPrefixSuffix, 2, 8, "*"))
  policy.rules.push(RedactRule::new(Phone, KeepPrefixSuffix, 3, 4, "*"))
  policy.rules.push(RedactRule::new(IdCard, KeepPrefixSuffix, 3, 2, "*"))
  policy.rules.push(RedactRule::new(BankCard, KeepPrefixSuffix, 4, 4, "*"))
  policy.rules.push(RedactRule::new(Token, HashLabel, 0, 0, "[TOKEN]"))
  policy.rules.push(RedactRule::new(Secret, Full, 0, 0, "[SECRET]"))
  policy.rules.push(RedactRule::new(IpAddress, KeepPrefixSuffix, 3, 0, "*"))
  policy
}

///|
pub fn RedactPolicy::logs() -> RedactPolicy {
  let policy = RedactPolicy::strict()
  {
    name: "logs",
    default_mode: policy.default_mode,
    rules: policy.rules,
    min_confidence_bp: 7000,
    fail_closed: policy.fail_closed,
  }
}

///|
pub fn RedactPolicy::allow_ip() -> RedactPolicy {
  let policy = RedactPolicy::strict()
  policy.rules.push(RedactRule::new(IpAddress, Pass, 0, 0, ""))
  {
    name: "allow-ip",
    default_mode: policy.default_mode,
    rules: policy.rules,
    min_confidence_bp: policy.min_confidence_bp,
    fail_closed: policy.fail_closed,
  }
}

///|
pub fn RedactPolicy::rule_for(
  self : RedactPolicy,
  kind : SensitiveKind,
) -> RedactRule {
  for rule in self.rules {
    if rule.kind == kind {
      return rule
    }
  }
  RedactRule::new(kind, self.default_mode, 1, 1, "*")
}

///|
pub fn RedactPolicy::accepts(
  self : RedactPolicy,
  item : SensitiveMatch,
) -> Bool {
  item.confidence_bp >= self.min_confidence_bp
}
