///|
/// Stateful chunk-safe redaction for log writers, exporters, and SDK buffers.
///
/// It delays an unfinished field until a delimiter is safely beyond the retained
/// tail, preventing a secret split across two chunks from escaping unredacted.
pub(all) struct RedactionStream {
  policy : RedactPolicy
  retain_tail : Int
  mut pending : String
} derive(Debug)

///|
pub fn RedactionStream::new(
  policy : RedactPolicy,
  retain_tail? : Int = 96,
) -> RedactionStream {
  { policy, retain_tail: max_int(16, retain_tail), pending: "" }
}

///|
/// Accepts one arbitrary log chunk and returns only a safely finalized prefix.
pub fn RedactionStream::push(self : RedactionStream, chunk : String) -> String {
  let combined = self.pending + chunk
  if combined.length() <= self.retain_tail {
    self.pending = combined
    return ""
  }
  let preferred = combined.length() - self.retain_tail
  let split_at = last_safe_delimiter(combined, preferred)
  if split_at == 0 {
    self.pending = combined
    return ""
  }
  let stable = substring(combined, 0, split_at)
  self.pending = substring(combined, split_at, combined.length())
  redact_text(stable, self.policy).output
}

///|
/// Redacts the remaining buffered field and resets the stream for reuse.
pub fn RedactionStream::finish(self : RedactionStream) -> String {
  let output = redact_text(self.pending, self.policy).output
  self.pending = ""
  output
}

///|
pub fn RedactionStream::pending_length(self : RedactionStream) -> Int {
  self.pending.length()
}

///|
fn last_safe_delimiter(source : String, preferred : Int) -> Int {
  let mut cursor = preferred
  while cursor > 0 {
    match source.get_char(cursor - 1) {
      Some(ch) if is_stream_delimiter(ch) => return cursor
      _ => cursor = cursor - 1
    }
  }
  0
}

///|
fn is_stream_delimiter(ch : Char) -> Bool {
  ch == ' ' || ch == '\n' || ch == '\t' || ch == ',' || ch == ';' || ch == '|'
}
