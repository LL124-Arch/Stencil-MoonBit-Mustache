///|
test "default compatibility corpus has practical coverage" {
  let cases = compatibility_cases()
  assert_eq(cases.length(), 20)
  let results = run_compatibility_suite(cases)
  let failures = compatibility_failures(results)
  assert_eq(failures.length(), 0)
  assert_eq(compatibility_summary(results), "cases=20, passed=20, failed=0")
}

///|
test "compatibility runner retains wrong expected output" {
  let cases = [
    CompatibilityCase::new("deliberate", "{{x}}", { "x": "actual" }, "expected"),
  ]
  let results = run_compatibility_suite(cases)
  assert_eq(results.length(), 1)
  assert_eq(compatibility_failures(results).length(), 1)
  assert_eq(results[0].actual, "actual")
}

///|
test "compatibility runner records compile errors" {
  let cases = [CompatibilityCase::new("broken", "{{#x}}", {}, "")]
  let results = run_compatibility_suite(cases)
  assert_eq(results[0].passed, false)
  assert_eq(results[0].error, "unclosed section: x")
}

///|
test "compatibility cases cover escaping and raw output" {
  let cases = compatibility_cases()
  let results = run_compatibility_suite(cases)
  assert_eq(results[1].actual, "&lt;b&gt;&amp;")
  assert_eq(results[2].actual, "<b>&")
  assert_eq(results[3].actual, "<i>")
}

///|
test "compatibility cases cover data contexts" {
  let results = run_compatibility_suite(compatibility_cases())
  assert_eq(results[4].actual, "Ada")
  assert_eq(results[8].actual, "a,b,")
  assert_eq(results[9].actual, "[a][b]")
  assert_eq(results[10].actual, "A/T")
}

///|
test "compatibility cases cover source formatting" {
  let results = run_compatibility_suite(compatibility_cases())
  assert_eq(results[15].actual, "before\nafter")
  assert_eq(results[16].actual, "MoonBit")
  assert_eq(results[18].actual, "你好，世界")
}
