///|
test "template introspection exposes source and top-level shape" {
  let template = compile("Hello {{name}}!")
  assert_eq(template.source_text(), "Hello {{name}}!")
  assert_eq(template.top_level_node_count(), 3)
  assert_eq(template.stats().is_empty(), false)
}

///|
test "compiled templates render batches deterministically" {
  let template = compile("{{name}}/{{role}}")
  let outputs = template.render_many([
    { "name": "Ada", "role": "admin" },
    { "name": "Lin", "role": "reviewer" },
    { "name": "Kai", "role": "guest" },
  ])
  assert_eq(outputs.length(), 3)
  assert_eq(outputs[0], "Ada/admin")
  assert_eq(outputs[2], "Kai/guest")
}

///|
test "batch rendering applies one shared safety policy" {
  let template = compile("{{value}}")
  let options = RenderOptions::default().with_escape_html(false)
  let outputs = template.render_many_with_options(
    [{ "value": "<a>" }, { "value": "<b>" }],
    options,
  )
  assert_eq(outputs.length(), 2)
  assert_eq(outputs[0], "<a>")
  assert_eq(outputs[1], "<b>")
}

///|
test "stats provide a complexity signal" {
  let stats = analyze("{{#items}}{{>card}}{{/items}}")
  assert_eq(stats.section_count, 1)
  assert_eq(stats.partial_count, 1)
  assert_eq(stats.complexity_score(), 8)
}
