///|
test "diagnostics identify malformed template location" {
  let diagnostics = diagnose("first\n{{#user}}\n{{/other}}")
  assert_eq(diagnostics.length(), 1)
  assert_eq(diagnostics[0].line, 3)
  assert_eq(diagnostics[0].column, 1)
  assert_eq(diagnostics[0].severity == DiagnosticSeverity::Error, true)
}

///|
test "diagnostics are empty for valid templates" {
  assert_eq(diagnose("Hello {{name}}").length(), 0)
}

///|
test "template stats expose reusable structure" {
  let template = compile("{{#user}}{{name}}{{>card}}{{/user}}")
  let stats = template.stats()
  assert_eq(stats.variable_count, 1)
  assert_eq(stats.section_count, 1)
  assert_eq(stats.partial_count, 1)
  assert_eq(stats.max_depth, 1)
  assert_eq(stats.node_count, 4)
}
