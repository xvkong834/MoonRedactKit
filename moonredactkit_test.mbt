///|
test "detects email and phone" {
  let matches = detect_all("user alice@example.com phone 15507714160")
  let summary = summarize_matches(matches)
  assert_eq(summary.email, 1)
  assert_eq(summary.phone, 1)
}

///|
test "detects id card bank card and ip" {
  let text = "id 11010119900307123X card 6222021234567890123 ip 10.2.3.4"
  let summary = summarize_matches(detect_all(text))
  assert_eq(summary.id_card, 1)
  assert_eq(summary.bank_card, 1)
  assert_eq(summary.ip_address, 1)
}

///|
test "detects token and marked secret" {
  let text = "api_key=abcdef1234567890abcdef token abcdef1234567890abcdef12"
  let summary = summarize_matches(detect_all(text))
  assert_true(summary.secret > 0)
  assert_true(summary.token > 0)
}

///|
test "mask keeps prefix and suffix" {
  assert_eq(mask_keep_edges("15507714160", 3, 4, "*"), "155****4160")
}

///|
test "strict policy redacts sensitive content" {
  let result = redact_text(
    "mail bob@example.com phone 15507714160",
    RedactPolicy::strict(),
  )
  assert_true(result.changed())
  assert_true(result.output.contains("bo"))
  assert_false(result.output.contains("15507714160"))
}

///|
test "hash label is stable" {
  let a = stable_fingerprint("abcdef123456")
  let b = stable_fingerprint("abcdef123456")
  assert_eq(a, b)
}

///|
test "summary marks high risk" {
  let summary = summarize_matches(detect_all("card 6222021234567890123"))
  assert_true(summary.has_high_risk())
}

///|
test "gate blocks secrets" {
  let result = redact_text(
    "password=verysecretvalue123",
    RedactPolicy::strict(),
  )
  let gate = evaluate_gate(LeakGate::new("ci", 0, 10, true), result)
  assert_false(gate.allowed())
  assert_eq(gate.reason, "secret_detected")
}

///|
test "gate warns on total threshold" {
  let result = redact_text(
    "a@example.com b@example.com c@example.com",
    RedactPolicy::strict(),
  )
  let gate = evaluate_gate(LeakGate::new("audit", 10, 1, false), result)
  assert_true(gate.level == Warn)
}

///|
test "batch report counts blocked jobs" {
  let report = run_batch(
    [
      RedactJob::new("ok", "hello"),
      RedactJob::new("bad", "secret=abcdef123456789"),
    ],
    RedactPolicy::strict(),
    LeakGate::new("ci", 0, 10, true),
  )
  assert_eq(report.jobs.length(), 2)
  assert_eq(report.blocked, 1)
  assert_false(report.passed())
}

///|
test "field evaluation tracks configured paths" {
  let findings = evaluate_fields(
    [FieldValue::new("user.email", "alice@example.com")],
    [FieldRule::new("user.email", Email, true)],
    RedactPolicy::strict(),
  )
  assert_eq(findings.length(), 1)
  assert_true(findings[0].present)
  assert_true(findings[0].redacted)
}

///|
test "json exports key metrics" {
  let result = redact_text("alice@example.com", RedactPolicy::strict())
  assert_true(result.to_json().contains("\"redactions\":1"))
  assert_true(result.summary().to_json().contains("\"email\":1"))
  assert_true(
    evaluate_gate(LeakGate::new("ci", 1, 10, false), result)
    .to_json()
    .contains("\"gate\":\"ci\""),
  )
}
