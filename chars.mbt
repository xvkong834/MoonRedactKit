///|
pub fn is_digit_char(ch : Char) -> Bool {
  ch >= '0' && ch <= '9'
}

///|
pub fn is_alpha_char(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')
}

///|
pub fn is_word_char(ch : Char) -> Bool {
  is_alpha_char(ch) || is_digit_char(ch) || ch == '_' || ch == '-' || ch == '.'
}

///|
pub fn is_hex_char(ch : Char) -> Bool {
  is_digit_char(ch) || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F')
}

///|
pub fn is_phone_separator(ch : Char) -> Bool {
  ch == ' ' || ch == '-' || ch == '(' || ch == ')' || ch == '+'
}

///|
pub fn is_boundary(source : String, index : Int) -> Bool {
  if index < 0 || index >= source.length() {
    true
  } else {
    match source.get_char(index) {
      Some(ch) =>
        !(is_alpha_char(ch) || is_digit_char(ch) || ch == '_' || ch == '-')
      None => true
    }
  }
}

///|
pub fn substring(source : String, start : Int, end : Int) -> String {
  source.unsafe_substring(start~, end~)
}

///|
pub fn repeat_mask(count : Int, mask : String) -> String {
  let buf = StringBuilder()
  for i = 0; i < count; i = i + 1 {
    buf.write_string(mask)
  }
  buf.to_string()
}
