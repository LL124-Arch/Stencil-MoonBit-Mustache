///|
test "options disable html escaping without changing legacy defaults" {
  let options = RenderOptions::default().with_escape_html(false)
  assert_eq(
    render_with_options("{{value}}", { "value": "<b>raw</b>" }, options),
    "<b>raw</b>",
  )
  assert_eq(
    render("{{value}}", { "value": "<b>raw</b>" }),
    "&lt;b&gt;raw&lt;/b&gt;",
  )
}

///|
test "options report missing partials when configured" {
  let options = RenderOptions::default().with_missing_partial(
    MissingPartialPolicy::Error,
  )
  try {
    ignore(render_with_options_and_partials("A{{>missing}}B", {}, {}, options))
    fail("expected missing partial error")
  } catch {
    TemplateError(message) => assert_eq(message, "missing partial: missing")
    _ => fail("expected TemplateError")
  }
}

///|
test "options enforce a small output limit" {
  let options = RenderOptions::default().with_max_output_length(3)
  try {
    ignore(render_with_options("hello", {}, options))
    fail("expected output limit error")
  } catch {
    TemplateError(message) =>
      assert_eq(message, "rendered output exceeds configured limit")
    _ => fail("expected TemplateError")
  }
}
