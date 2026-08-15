/// Final acceptance boundary cases.

///|
test "final boundary empty object" {
  assert_eq(render("{{#object}}ok{{/object}}", { "object": {} }), "ok")
}

///|
test "final boundary object nested value" {
  assert_eq(
    render("{{#object}}{{value}}{{/object}}", { "object": { "value": "ok" } }),
    "ok",
  )
}

///|
test "final boundary repeated section" {
  assert_eq(render("{{#x}}a{{/x}}{{#x}}b{{/x}}", { "x": true }), "ab")
}

///|
test "final boundary missing section" {
  assert_eq(
    render("{{#missing}}a{{/missing}}{{^missing}}b{{/missing}}", {}),
    "b",
  )
}

///|
test "final boundary partial with variable" {
  assert_eq(
    render_with_partials("{{>p}}", { "x": "ok" }, { "p": "{{x}}" }),
    "ok",
  )
}

///|
test "final boundary partial preserve policy" {
  let options = RenderOptions::default().with_missing_partial(
    MissingPartialPolicy::Preserve,
  )
  assert_eq(
    render_with_options_and_partials("{{>p}}", {}, {}, options),
    "{{>p}}",
  )
}

///|
test "final boundary partial error policy" {
  let options = RenderOptions::default().with_missing_partial(
    MissingPartialPolicy::Error,
  )
  try {
    ignore(render_with_options_and_partials("{{>p}}", {}, {}, options))
    fail("expected missing partial")
  } catch {
    TemplateError(message) => assert_eq(message, "missing partial: p")
    _ => fail("expected TemplateError")
  }
}

///|
test "final boundary stats summary is populated" {
  let summary = compile("{{name}}").stats().summary()
  assert_eq(summary.contains("nodes="), true)
  assert_eq(summary.contains("vars=1"), true)
}

///|
test "final boundary diagnostic summary is populated" {
  let summary = diagnose("{{#x}}")[0].summary()
  assert_eq(summary.contains("error at 1:1"), true)
}

///|
test "final boundary benchmark checksum is deterministic" {
  let first = run_benchmark(production_benchmark_workload())
  let second = run_benchmark(production_benchmark_workload())
  assert_eq(first.checksum, second.checksum)
  assert_eq(first.output_length, second.output_length)
}

///|
test "final boundary compatibility is deterministic" {
  let first = compatibility_summary(
    run_compatibility_suite(compatibility_cases()),
  )
  let second = compatibility_summary(
    run_compatibility_suite(compatibility_cases()),
  )
  assert_eq(first, second)
}
