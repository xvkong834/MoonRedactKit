///|
pub fn apply_mask(item : SensitiveMatch, rule : RedactRule) -> String {
  match rule.mode {
    Pass => item.text
    Drop => ""
    Full => rule.replacement
    HashLabel => "\{rule.replacement}#\{stable_fingerprint(item.text)}"
    KeepPrefixSuffix =>
      mask_keep_edges(
        item.text,
        rule.keep_prefix,
        rule.keep_suffix,
        rule.replacement,
      )
  }
}

///|
pub fn mask_keep_edges(
  value : String,
  keep_prefix : Int,
  keep_suffix : Int,
  mask : String,
) -> String {
  if value.length() <= keep_prefix + keep_suffix {
    repeat_mask(value.length(), mask)
  } else {
    let prefix = substring(value, 0, keep_prefix)
    let suffix = substring(value, value.length() - keep_suffix, value.length())
    let middle = repeat_mask(value.length() - keep_prefix - keep_suffix, mask)
    "\{prefix}\{middle}\{suffix}"
  }
}

///|
pub fn stable_fingerprint(value : String) -> Int {
  let mut hash = 5381
  for i = 0; i < value.length(); i = i + 1 {
    match value.get_char(i) {
      Some(ch) => hash = hash * 33 + ch.to_int()
      None => ()
    }
  }
  if hash < 0 {
    -hash
  } else {
    hash
  }
}
