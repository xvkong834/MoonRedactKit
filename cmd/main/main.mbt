///|
fn main {
  let input = "login alice@example.com phone 15507714160 password=verysecretvalue123"
  let result = @redact.redact_text(input, @redact.RedactPolicy::strict())
  let gate = @redact.evaluate_gate(
    @redact.LeakGate::new("ci-log", 0, 10, true),
    result,
  )
  println("MoonRedactKit demo")
  println(result.output)
  println(result.to_json())
  println(gate.to_json())
  let stream = @redact.RedactionStream::new(@redact.RedactPolicy::strict())
  let first = stream.push("event=login password=verysec")
  let second = stream.push("retvalue123 user=alice ")
  println(first + second + stream.finish())
  let audit = @redact.summarize_matches(
    @redact.detect_all("card 6222021234567890123 ip 10.2.3.4"),
  )
  println(audit.to_json())
}
