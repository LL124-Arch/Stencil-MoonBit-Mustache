/// Resource-limit and failure-mode coverage.

///|
fn nested_section_source(depth : Int) -> String {
  let buf = StringBuilder::new()
  for _ in 0..<depth {
    buf.write_string("{{#x}}")
  }
  for _ in 0..<depth {
    buf.write_string("{{/x}}")
  }
  buf.to_string()
}

///|
fn partial_chain(count : Int) -> Map[String, String] {
  let result : Map[String, String] = Map([])
  if count == 0 {
    return result
  }
  for i = 0; i < count; i = i + 1 {
    let next = if i + 1 < count { "p" + (i + 1).to_string() } else { "done" }
    result.set("p" + i.to_string(), "{{>" + next + "}}")
  }
  result.set("done", "ok")
  result
}

///|
test "zero limits mean unlimited for ordinary templates" {
  let options = RenderOptions::default().with_max_nesting_depth(0)
  let source = nested_section_source(32)
  let data : Json = { "x": true }
  let result = render_with_options(source, data, options)
  assert_eq(result, "")
}

///|
test "negative limits normalize to unlimited" {
  let options = RenderOptions::default()
    .with_max_nesting_depth(-1)
    .with_max_partial_depth(-1)
    .with_max_output_length(-1)
  assert_eq(options.max_nesting_depth(), 0)
  assert_eq(options.max_partial_depth(), 0)
  assert_eq(options.max_output_length(), 0)
}

///|
test "section limit rejects deep expansion" {
  let options = RenderOptions::default().with_max_nesting_depth(2)
  try {
    ignore(
      render_with_options(
        "{{#x}}{{#x}}{{#x}}ok{{/x}}{{/x}}{{/x}}",
        { "x": true },
        options,
      ),
    )
    fail("expected nesting limit")
  } catch {
    TemplateError(message) =>
      assert_eq(message, "maximum render nesting depth exceeded")
    _ => fail("expected TemplateError")
  }
}

///|
test "partial limit rejects long chains" {
  let options = RenderOptions::default().with_max_partial_depth(3)
  try {
    ignore(
      render_with_options_and_partials("{{>p0}}", {}, partial_chain(8), options),
    )
    fail("expected partial limit")
  } catch {
    TemplateError(message) =>
      assert_eq(message, "maximum partial nesting depth exceeded")
    _ => fail("expected TemplateError")
  }
}

///|
test "partial cycle policy reports the first repeated name" {
  let options = RenderOptions::default().with_partial_cycle_detection(true)
  let partials : Map[String, String] = { "a": "{{>b}}", "b": "{{>a}}" }
  try {
    ignore(render_with_options_and_partials("{{>a}}", {}, partials, options))
    fail("expected cycle error")
  } catch {
    TemplateError(message) => assert_eq(message, "partial cycle detected: a")
    _ => fail("expected TemplateError")
  }
}

///|
test "missing partial can be preserved for a later pass" {
  let options = RenderOptions::default().with_missing_partial(
    MissingPartialPolicy::Preserve,
  )
  let output = render_with_options_and_partials(
    "A {{>later}} B",
    {},
    {},
    options,
  )
  assert_eq(output, "A {{>later}} B")
}

///|
test "output limit applies to plain text" {
  let options = RenderOptions::default().with_max_output_length(4)
  try {
    ignore(render_with_options("12345", {}, options))
    fail("expected output limit")
  } catch {
    TemplateError(message) =>
      assert_eq(message, "rendered output exceeds configured limit")
    _ => fail("expected TemplateError")
  }
}

///|
test "output limit applies after list expansion" {
  let options = RenderOptions::default().with_max_output_length(3)
  let data : Json = { "items": [1, 2, 3, 4] }
  try {
    ignore(render_with_options("{{#items}}x{{/items}}", data, options))
    fail("expected output limit")
  } catch {
    TemplateError(message) =>
      assert_eq(message, "rendered output exceeds configured limit")
    _ => fail("expected TemplateError")
  }
}
