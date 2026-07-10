///|
pub(all) struct DetectorConfig {
  min_token_length : Int
  min_secret_length : Int
  detect_ip : Bool
} derive(Eq, Debug)

///|
pub fn DetectorConfig::default() -> DetectorConfig {
  { min_token_length: 20, min_secret_length: 12, detect_ip: true }
}

///|
pub fn detect_all(source : String) -> Array[SensitiveMatch] {
  detect_with_config(source, DetectorConfig::default())
}

///|
pub fn detect_with_config(
  source : String,
  config : DetectorConfig,
) -> Array[SensitiveMatch] {
  let matches = []
  append_email_matches(matches, source)
  append_phone_matches(matches, source)
  append_id_card_matches(matches, source)
  append_bank_card_matches(matches, source)
  append_token_matches(matches, source, config.min_token_length)
  append_secret_key_matches(matches, source, config.min_secret_length)
  if config.detect_ip {
    append_ip_matches(matches, source)
  }
  normalize_matches(matches)
}

///|
fn append_email_matches(
  matches : Array[SensitiveMatch],
  source : String,
) -> Unit {
  for i = 0; i < source.length(); i = i + 1 {
    if source.get_char(i) == Some('@') {
      let mut start = i - 1
      while start >= 0 && is_word_char(source.get_char(start).unwrap()) {
        start = start - 1
      }
      start = start + 1
      let mut end = i + 1
      while end < source.length() && is_word_char(source.get_char(end).unwrap()) {
        end = end + 1
      }
      if start < i && end > i + 3 && substring(source, i + 1, end).contains(".") {
        matches.push(
          SensitiveMatch::new(
            Email,
            start,
            end,
            substring(source, start, end),
            9500,
            "email-scan",
          ),
        )
      }
    }
  }
}

///|
fn append_phone_matches(
  matches : Array[SensitiveMatch],
  source : String,
) -> Unit {
  let mut i = 0
  while i < source.length() {
    match source.get_char(i) {
      Some(ch) if is_digit_char(ch) || ch == '+' => {
        let start = i
        let mut end = i
        let mut last_digit_end = i
        let mut digits = 0
        while end < source.length() {
          let current = source.get_char(end).unwrap()
          if is_digit_char(current) {
            digits = digits + 1
            end = end + 1
            last_digit_end = end
          } else if is_phone_separator(current) {
            end = end + 1
          } else {
            break
          }
        }
        let first = source.get_char(start)
        end = last_digit_end
        if digits >= 11 &&
          digits <= 15 &&
          first == Some('1') &&
          is_boundary(source, start - 1) &&
          is_boundary(source, end) {
          matches.push(
            SensitiveMatch::new(
              Phone,
              start,
              end,
              substring(source, start, end),
              9000,
              "phone-scan",
            ),
          )
        }
        i = max_int(end, i + 1)
      }
      _ => i = i + 1
    }
  }
}

///|
fn append_id_card_matches(
  matches : Array[SensitiveMatch],
  source : String,
) -> Unit {
  let mut i = 0
  while i + 18 <= source.length() {
    if is_boundary(source, i - 1) && is_boundary(source, i + 18) {
      let mut ok = true
      for j = 0; j < 17; j = j + 1 {
        ok = ok && is_digit_char(source.get_char(i + j).unwrap())
      }
      let last = source.get_char(i + 17).unwrap()
      ok = ok && (is_digit_char(last) || last == 'X' || last == 'x')
      if ok {
        matches.push(
          SensitiveMatch::new(
            IdCard,
            i,
            i + 18,
            substring(source, i, i + 18),
            9200,
            "id-card-scan",
          ),
        )
        i = i + 18
      } else {
        i = i + 1
      }
    } else {
      i = i + 1
    }
  }
}

///|
fn append_bank_card_matches(
  matches : Array[SensitiveMatch],
  source : String,
) -> Unit {
  let mut i = 0
  while i < source.length() {
    if source.get_char(i).map_or(false, is_digit_char) {
      let start = i
      let mut end = i
      let mut last_digit_end = i
      let mut digits = 0
      while end < source.length() {
        let ch = source.get_char(end).unwrap()
        if is_digit_char(ch) {
          digits = digits + 1
          end = end + 1
          last_digit_end = end
        } else if ch == ' ' || ch == '-' {
          end = end + 1
        } else {
          break
        }
      }
      end = last_digit_end
      if digits >= 13 &&
        digits <= 19 &&
        is_boundary(source, start - 1) &&
        is_boundary(source, end) {
        matches.push(
          SensitiveMatch::new(
            BankCard,
            start,
            end,
            substring(source, start, end),
            8400,
            "bank-card-scan",
          ),
        )
      }
      i = max_int(end, i + 1)
    } else {
      i = i + 1
    }
  }
}

///|
fn append_token_matches(
  matches : Array[SensitiveMatch],
  source : String,
  min_length : Int,
) -> Unit {
  let mut i = 0
  while i < source.length() {
    if source.get_char(i).map_or(false, is_alpha_char) {
      let start = i
      let mut end = i
      let mut hex = 0
      let mut digits = 0
      while end < source.length() {
        let ch = source.get_char(end).unwrap()
        if is_alpha_char(ch) || is_digit_char(ch) || ch == '_' || ch == '-' {
          if is_hex_char(ch) {
            hex = hex + 1
          }
          if is_digit_char(ch) {
            digits = digits + 1
          }
          end = end + 1
        } else {
          break
        }
      }
      let length = end - start
      if length >= min_length && digits >= 4 && hex * 100 / length >= 60 {
        matches.push(
          SensitiveMatch::new(
            Token,
            start,
            end,
            substring(source, start, end),
            7600,
            "token-entropy-scan",
          ),
        )
      }
      i = max_int(end, i + 1)
    } else {
      i = i + 1
    }
  }
}

///|
fn append_secret_key_matches(
  matches : Array[SensitiveMatch],
  source : String,
  min_length : Int,
) -> Unit {
  let markers = ["password=", "passwd=", "secret=", "api_key=", "token="]
  for marker in markers {
    let mut i = 0
    while i + marker.length() < source.length() {
      if substring(source, i, min_int(i + marker.length(), source.length())) ==
        marker {
        let start = i + marker.length()
        let mut end = start
        while end < source.length() && !is_boundary(source, end) {
          end = end + 1
        }
        if end - start >= min_length {
          matches.push(
            SensitiveMatch::new(
              Secret,
              start,
              end,
              substring(source, start, end),
              9400,
              "secret-marker-scan",
            ),
          )
        }
        i = max_int(end, i + 1)
      } else {
        i = i + 1
      }
    }
  }
}

///|
fn append_ip_matches(matches : Array[SensitiveMatch], source : String) -> Unit {
  let mut i = 0
  while i < source.length() {
    if source.get_char(i).map_or(false, is_digit_char) {
      let start = i
      let mut end = i
      let mut dots = 0
      while end < source.length() {
        let ch = source.get_char(end).unwrap()
        if is_digit_char(ch) {
          end = end + 1
        } else if ch == '.' {
          dots = dots + 1
          end = end + 1
        } else {
          break
        }
      }
      if dots == 3 &&
        valid_ipv4_candidate(source, start, end) &&
        is_boundary(source, start - 1) &&
        is_boundary(source, end) {
        matches.push(
          SensitiveMatch::new(
            IpAddress,
            start,
            end,
            substring(source, start, end),
            7000,
            "ip-scan",
          ),
        )
      }
      i = max_int(end, i + 1)
    } else {
      i = i + 1
    }
  }
}

///|
fn valid_ipv4_candidate(source : String, start : Int, end : Int) -> Bool {
  let mut parts = 1
  let mut value = 0
  let mut digits = 0
  for i = start; i < end; i = i + 1 {
    let ch = source.get_char(i).unwrap()
    if is_digit_char(ch) {
      value = value * 10 + digit_value(ch)
      digits = digits + 1
      if digits > 3 || value > 255 {
        return false
      }
    } else if ch == '.' {
      if digits == 0 {
        return false
      }
      parts = parts + 1
      value = 0
      digits = 0
    } else {
      return false
    }
  }
  parts == 4 && digits > 0
}

///|
fn digit_value(ch : Char) -> Int {
  match ch {
    '0' => 0
    '1' => 1
    '2' => 2
    '3' => 3
    '4' => 4
    '5' => 5
    '6' => 6
    '7' => 7
    '8' => 8
    '9' => 9
    _ => 0
  }
}

///|
fn normalize_matches(input : Array[SensitiveMatch]) -> Array[SensitiveMatch] {
  let output : Array[SensitiveMatch] = []
  for item in input {
    let mut overlap = false
    let mut replace_at = -1
    for current in output {
      if item.start < current.end && current.start < item.end {
        overlap = true
      }
    }
    for i = 0; i < output.length(); i = i + 1 {
      if item.start < output[i].end &&
        output[i].start < item.end &&
        item.confidence_bp > output[i].confidence_bp {
        replace_at = i
      }
    }
    if replace_at >= 0 {
      output[replace_at] = item
    } else if !overlap {
      output.push(item)
    }
  }
  output
}
