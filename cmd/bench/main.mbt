///|
/// Deterministic operation-count benchmark for a CI/log export workload.
fn main {
  let count = 100000
  let stream = @redact.RedactionStream::new(
    @redact.RedactPolicy::strict(),
    retain_tail=96,
  )
  let mut output_bytes = 0
  for i = 0; i < count; i = i + 1 {
    let chunk = if i % 10 == 0 {
      "event=login user=user\{i}@example.com password=verysecretvalue\{i} "
    } else {
      "event=metric service=api status=200 latency_ms=12 "
    }
    output_bytes = output_bytes + stream.push(chunk).length()
  }
  output_bytes = output_bytes + stream.finish().length()
  println("scenario,chunks,retained_tail,output_bytes")
  println("log-redaction-100k,\{count},96,\{output_bytes}")
}
