/// A small executable compatibility corpus for regression and acceptance work.

///|
pub(all) struct CompatibilityCase {
  name : String
  template : String
  data : Json
  expected : String
} derive(Debug)

///|
pub(all) struct CompatibilityResult {
  name : String
  passed : Bool
  actual : String
  expected : String
  error : String
} derive(Debug)

///|
pub fn CompatibilityCase::new(
  name : String,
  template : String,
  data : Json,
  expected : String,
) -> CompatibilityCase {
  { name, template, data, expected }
}

///|
/// The corpus is intentionally made of practical snippets rather than parser
/// micro-cases: pages, emails, lists, localization, and safe HTML output.
pub fn compatibility_cases() -> Array[CompatibilityCase] {
  [
    CompatibilityCase::new("plain text", "hello", {}, "hello"),
    CompatibilityCase::new(
      "escaped html",
      "{{value}}",
      { "value": "<b>&" },
      "&lt;b&gt;&amp;",
    ),
    CompatibilityCase::new(
      "raw html",
      "{{{value}}}",
      { "value": "<b>&" },
      "<b>&",
    ),
    CompatibilityCase::new(
      "ampersand raw",
      "{{&value}}",
      { "value": "<i>" },
      "<i>",
    ),
    CompatibilityCase::new(
      "dotted lookup",
      "{{user.name}}",
      { "user": { "name": "Ada" } },
      "Ada",
    ),
    CompatibilityCase::new(
      "boolean section",
      "{{#active}}yes{{/active}}",
      { "active": true },
      "yes",
    ),
    CompatibilityCase::new(
      "boolean inverted",
      "{{^active}}no{{/active}}",
      { "active": false },
      "no",
    ),
    CompatibilityCase::new(
      "empty list inverted",
      "{{#items}}items{{/items}}{{^items}}empty{{/items}}",
      { "items": [] },
      "empty",
    ),
    CompatibilityCase::new(
      "list iteration",
      "{{#items}}{{name}},{{/items}}",
      { "items": [{ "name": "a" }, { "name": "b" }] },
      "a,b,",
    ),
    CompatibilityCase::new(
      "implicit iterator",
      "{{#items}}[{{.}}]{{/items}}",
      { "items": ["a", "b"] },
      "[a][b]",
    ),
    CompatibilityCase::new(
      "nested context",
      "{{#user}}{{name}}/{{#team}}{{name}}{{/team}}{{/user}}",
      { "user": { "name": "A", "team": { "name": "T" } } },
      "A/T",
    ),
    CompatibilityCase::new("comment", "a{{! hidden }}b", {}, "ab"),
    CompatibilityCase::new("missing variable", "a{{missing}}b", {}, "ab"),
    CompatibilityCase::new("number", "{{count}}", { "count": 42 }, "42"),
    CompatibilityCase::new(
      "numeric section",
      "{{#count}}yes{{/count}}{{^count}}no{{/count}}",
      { "count": 0 },
      "yes",
    ),
    CompatibilityCase::new(
      "standalone comment",
      "before\n  {{! comment}}\nafter",
      {},
      "before\nafter",
    ),
    CompatibilityCase::new(
      "delimiter change",
      "{{=<% %>=}}<%name%>",
      { "name": "MoonBit" },
      "MoonBit",
    ),
    CompatibilityCase::new(
      "mixed literal",
      "v{{name}}!",
      { "name": "x" },
      "vx!",
    ),
    CompatibilityCase::new(
      "unicode text",
      "你好，{{name}}",
      { "name": "世界" },
      "你好，世界",
    ),
    CompatibilityCase::new("newline", "a\nb\n", {}, "a\nb\n"),
  ]
}

///|
/// Execute the corpus and retain failures instead of stopping at the first.
pub fn run_compatibility_suite(
  cases : Array[CompatibilityCase],
) -> Array[CompatibilityResult] {
  let results : Array[CompatibilityResult] = []
  for case_ in cases {
    try {
      let actual = render(case_.template, case_.data)
      results.push({
        name: case_.name,
        passed: actual == case_.expected,
        actual,
        expected: case_.expected,
        error: "",
      })
    } catch {
      TemplateError(message) =>
        results.push({
          name: case_.name,
          passed: false,
          actual: "",
          expected: case_.expected,
          error: message,
        })
    }
  }
  results
}

///|
pub fn compatibility_failures(
  results : Array[CompatibilityResult],
) -> Array[CompatibilityResult] {
  let failures : Array[CompatibilityResult] = []
  for result in results {
    if !result.passed {
      failures.push(result)
    }
  }
  failures
}

///|
pub fn compatibility_summary(results : Array[CompatibilityResult]) -> String {
  let failures = compatibility_failures(results)
  "cases=\{results.length()}, passed=\{results.length() - failures.length()}, failed=\{failures.length()}"
}
