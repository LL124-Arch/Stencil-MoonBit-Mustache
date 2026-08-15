/// Public API regression cases retained as executable documentation.

///|
test "api default options preserve escaping" {
  assert_eq(RenderOptions::default().escape_html(), true)
  assert_eq(render("{{x}}", { "x": "<" }), "&lt;")
}

///|
test "api options are immutable values" {
  let defaults = RenderOptions::default()
  let raw = defaults.with_escape_html(false)
  assert_eq(defaults.escape_html(), true)
  assert_eq(raw.escape_html(), false)
}

///|
test "api standalone option is inspectable" {
  let options = RenderOptions::default().with_standalone_lines(false)
  assert_eq(options.standalone_lines(), false)
}

///|
test "api missing policy round trip" {
  let options = RenderOptions::default().with_missing_partial(
    MissingPartialPolicy::Preserve,
  )
  assert_eq(options.missing_partial() == MissingPartialPolicy::Preserve, true)
}

///|
test "api nesting limits round trip" {
  let options = RenderOptions::default()
    .with_max_nesting_depth(7)
    .with_max_partial_depth(9)
  assert_eq(options.max_nesting_depth(), 7)
  assert_eq(options.max_partial_depth(), 9)
}

///|
test "api output limit round trip" {
  let options = RenderOptions::default().with_max_output_length(123)
  assert_eq(options.max_output_length(), 123)
}

///|
test "api cycle flag round trip" {
  let options = RenderOptions::default().with_partial_cycle_detection(true)
  assert_eq(options.detect_partial_cycles(), true)
}

///|
test "api compile returns reusable source" {
  let template = compile("{{x}}")
  assert_eq(template.source_text(), "{{x}}")
  assert_eq(template.render({ "x": "a" }), "a")
  assert_eq(template.render({ "x": "b" }), "b")
}

///|
test "api compile stats count raw variables" {
  let stats = compile("{{{html}}}").stats()
  assert_eq(stats.raw_variable_count, 1)
  assert_eq(stats.variable_count, 0)
}

///|
test "api compile stats count inverted sections" {
  let stats = compile("{{^empty}}fallback{{/empty}}").stats()
  assert_eq(stats.inverted_section_count, 1)
  assert_eq(stats.section_count, 0)
}

///|
test "api compile stats detect custom delimiters" {
  let stats = compile("{{=<% %>=}}<%x%>").stats()
  assert_eq(stats.has_custom_delimiters, true)
}

///|
test "api diagnostics expose source coordinates" {
  let diagnostics = diagnose("a\n{{#x}}\n{{/y}}")
  assert_eq(diagnostics.length(), 1)
  assert_eq(diagnostics[0].line, 3)
  assert_eq(diagnostics[0].column, 1)
  assert_eq(diagnostics[0].index > 0, true)
}

///|
test "api diagnostics summarize errors" {
  let diagnostics = diagnose("{{#x}}")
  let summary = diagnostics[0].summary()
  assert_eq(summary.contains("1:1"), true)
  assert_eq(summary.contains("unclosed section"), true)
}

///|
test "api partial store starts empty" {
  let store = PartialStore::new()
  assert_eq(store.names().length(), 0)
  assert_eq(store.contains("missing"), false)
}

///|
test "api partial store replacement is visible" {
  let store = PartialStore::new()
  store.set("p", "one")
  store.set("p", "two")
  assert_eq(store.get("p") is Some("two"), true)
  assert_eq(store.render("{{>p}}", {}), "two")
}

///|
test "api partial store removes missing safely" {
  let store = PartialStore::new()
  store.remove("never")
  store.set("p", "ok")
  store.remove("p")
  assert_eq(store.contains("p"), false)
}

///|
test "api partial store options reach renderer" {
  let store = PartialStore::from_map({ "p": "{{x}}" })
  let options = RenderOptions::default().with_escape_html(false)
  assert_eq(store.render_with_options("{{>p}}", { "x": "<" }, options), "<")
}

///|
test "api partial store reports missing metric source" {
  try {
    ignore(PartialStore::new().stats("none"))
    fail("expected missing")
  } catch {
    TemplateError(message) => assert_eq(message, "missing partial: none")
    _ => fail("expected TemplateError")
  }
}

///|
test "api analyze matches compiled stats" {
  let source = "{{#x}}ok{{/x}}"
  let analyzed = analyze(source)
  let compiled = compile(source).stats()
  assert_eq(analyzed.node_count, compiled.node_count)
  assert_eq(analyzed.section_count, compiled.section_count)
  assert_eq(analyzed.max_depth, compiled.max_depth)
}

///|
test "api benchmark output is nonempty" {
  let result = run_benchmark(production_benchmark_workload())
  assert_eq(result.output_length > 100, true)
  assert_eq(result.total_output_length > 10000, true)
}

///|
test "api compatibility summary counts all cases" {
  let summary = compatibility_summary(
    run_compatibility_suite(compatibility_cases()),
  )
  assert_eq(summary, "cases=20, passed=20, failed=0")
}

///|
test "api legacy invalid partial remains empty" {
  assert_eq(render_with_partials("A{{>bad}}B", {}, { "bad": "{{#x}}" }), "AB")
}

///|
test "api checked invalid partial is visible" {
  try {
    ignore(
      render_with_options_and_partials(
        "A{{>bad}}B",
        {},
        { "bad": "{{#x}}" },
        RenderOptions::default(),
      ),
    )
    fail("expected invalid partial")
  } catch {
    TemplateError(message) => assert_eq(message, "unclosed section: x")
    _ => fail("expected TemplateError")
  }
}

///|
test "api empty stats are explicit" {
  assert_eq(compile("").stats().is_empty(), true)
  assert_eq(compile("").stats().complexity_score(), 0)
}

///|
test "api plain text stats include root" {
  let stats = compile("plain").stats()
  assert_eq(stats.node_count, 2)
  assert_eq(stats.text_node_count, 1)
}
