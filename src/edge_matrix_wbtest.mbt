/// Parser and renderer edge matrix. Each case protects a documented boundary.

///|
test "edge empty template" {
  assert_eq(render("", {}), "")
}

///|
test "edge whitespace" {
  assert_eq(render("   \t\n", {}), "   \t\n")
}

///|
test "edge adjacent variables" {
  assert_eq(render("{{a}}{{b}}{{c}}", { "a": "1", "b": "2", "c": "3" }), "123")
}

///|
test "edge variable with spaces" {
  assert_eq(render("{{  name  }}", { "name": "ok" }), "ok")
}

///|
test "edge raw triple tag" {
  assert_eq(render("{{{x}}}", { "x": "<&>\"'" }), "<&>\"'")
}

///|
test "edge ampersand tag" {
  assert_eq(render("{{&x}}", { "x": "<&>" }), "<&>")
}

///|
test "edge escaping ampersand" {
  assert_eq(render("{{x}}", { "x": "&" }), "&amp;")
}

///|
test "edge escaping quote" {
  assert_eq(render("{{x}}", { "x": "\"'" }), "&quot;&#39;")
}

///|
test "edge escaping slash" {
  assert_eq(render("{{x}}", { "x": "/" }), "/")
}

///|
test "edge missing dotted path" {
  assert_eq(render("{{a.b.c}}", { "a": {} }), "")
}

///|
test "edge dotted path through scalar" {
  assert_eq(render("{{a.b}}", { "a": "x" }), "")
}

///|
test "edge parent context fallback" {
  assert_eq(
    render("{{#user}}{{name}}/{{missing}}{{/user}}", {
      "name": "outer",
      "user": {},
    }),
    "outer/",
  )
}

///|
test "edge current iterator" {
  assert_eq(render("{{#items}}{{.}}{{/items}}", { "items": [1, 2, 3] }), "123")
}

///|
test "edge object stringification" {
  assert_eq(render("{{value}}", { "value": { "x": 1 } }), "[Object]")
}

///|
test "edge array stringification" {
  assert_eq(render("{{value}}", { "value": [1, 2] }), "[Array]")
}

///|
test "edge null value" {
  assert_eq(render("a{{value}}b", { "value": null }), "ab")
}

///|
test "edge false value" {
  assert_eq(render("{{value}}", { "value": false }), "false")
}

///|
test "edge true value" {
  assert_eq(render("{{value}}", { "value": true }), "true")
}

///|
test "edge zero value" {
  assert_eq(render("{{value}}", { "value": 0 }), "0")
}

///|
test "edge empty string section" {
  assert_eq(render("{{#x}}yes{{/x}}{{^x}}no{{/x}}", { "x": "" }), "no")
}

///|
test "edge empty array section" {
  assert_eq(render("{{#x}}yes{{/x}}{{^x}}no{{/x}}", { "x": [] }), "no")
}

///|
test "edge nonempty string section" {
  assert_eq(render("{{#x}}yes{{/x}}", { "x": "x" }), "yes")
}

///|
test "edge nested arrays" {
  assert_eq(
    render("{{#rows}}{{#.}}{{.}}{{/.}}{{/rows}}", { "rows": [[1, 2], [3]] }),
    "123",
  )
}

///|
test "edge crlf standalone" {
  assert_eq(render("before\r\n{{! c}}\r\nafter", {}), "before\r\nafter")
}

///|
test "edge standalone section" {
  assert_eq(render("{{#ok}}\nbody\n{{/ok}}", { "ok": true }), "body\n")
}

///|
test "edge inverted section" {
  assert_eq(render("{{^ok}}empty\n{{/ok}}", { "ok": false }), "empty\n")
}

///|
test "edge nested sections" {
  assert_eq(
    render("{{#a}}{{#b}}ok{{/b}}{{/a}}", { "a": true, "b": true }),
    "ok",
  )
}

///|
test "edge mismatched closing tag" {
  try {
    ignore(compile("{{#a}}{{/b}}"))
    fail("expected mismatch")
  } catch {
    TemplateError(message) =>
      assert_eq(message, "section close mismatch: expected a, got b")
    _ => fail("expected TemplateError")
  }
}

///|
test "edge unexpected closing tag" {
  try {
    ignore(compile("{{/a}}"))
    fail("expected unexpected close")
  } catch {
    TemplateError(message) => assert_eq(message, "unexpected closing tag: a")
    _ => fail("expected TemplateError")
  }
}

///|
test "edge unclosed section" {
  try {
    ignore(compile("{{#a}}"))
    fail("expected unclosed")
  } catch {
    TemplateError(message) => assert_eq(message, "unclosed section: a")
    _ => fail("expected TemplateError")
  }
}

///|
test "edge unclosed tag" {
  try {
    ignore(compile("a{{name"))
    fail("expected unclosed tag")
  } catch {
    TemplateError(message) => assert_eq(message, "unclosed tag at index 1")
    _ => fail("expected TemplateError")
  }
}

///|
test "edge delimiter content" {
  assert_eq(render("{{=<% %>=}}<%x%>", { "x": "ok" }), "ok")
}

///|
test "edge delimiter reset" {
  assert_eq(
    render("{{=<% %>=}}<%x%><%={{ }}=%>{{y}}", { "x": "a", "y": "b" }),
    "ab",
  )
}

///|
test "edge partial inline" {
  assert_eq(render_with_partials("A{{>p}}B", {}, { "p": "x" }), "AxB")
}

///|
test "edge partial empty" {
  assert_eq(render_with_partials("A{{>p}}B", {}, {}), "AB")
}

///|
test "edge partial multiline indentation" {
  assert_eq(render_with_partials("  {{>p}}", {}, { "p": "a\nb" }), "  a\n  b")
}

///|
test "edge partial unicode" {
  assert_eq(render_with_partials("{{>p}}", {}, { "p": "你好" }), "你好")
}

///|
test "edge partial source error is explicit in configured mode" {
  try {
    ignore(
      render_with_options_and_partials(
        "{{>p}}",
        {},
        { "p": "{{#x}}" },
        RenderOptions::default(),
      ),
    )
    fail("expected partial syntax error")
  } catch {
    TemplateError(message) => assert_eq(message, "unclosed section: x")
    _ => fail("expected TemplateError")
  }
}
