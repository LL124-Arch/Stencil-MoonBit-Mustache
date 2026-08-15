// Deterministic compatibility and boundary tests for the documented core.

///|
test "compatibility renders unicode without corruption" {
  let data : Json = { "name": "月兔 🚀 / MoonBit" }
  assert_eq(render("{{name}}", data), "月兔 🚀 / MoonBit")
}

///|
test "compatibility escapes unicode-adjacent html safely" {
  let data : Json = { "value": "中文 <tag> & \"quoted\"" }
  assert_eq(
    render("{{value}}", data),
    "中文 &lt;tag&gt; &amp; &quot;quoted&quot;",
  )
}

///|
test "compatibility preserves raw ampersand output" {
  assert_eq(
    render("{{&value}}", { "value": "<strong>ok</strong>" }),
    "<strong>ok</strong>",
  )
}

///|
test "compatibility keeps parent context visible in nested object" {
  let data : Json = { "title": "Report", "author": { "name": "Ada" } }
  assert_eq(
    render("{{#author}}{{name}} - {{title}}{{/author}}", data),
    "Ada - Report",
  )
}

///|
test "compatibility prefers nearest shadowed context" {
  let data : Json = { "name": "outer", "user": { "name": "inner" } }
  assert_eq(render("{{#user}}{{name}}{{/user}}", data), "inner")
}

///|
test "compatibility treats missing dotted path as empty" {
  let data : Json = { "user": { "profile": {} } }
  assert_eq(render("X{{user.profile.name}}Y", data), "XY")
}

///|
test "compatibility treats zero as a rendered truthy number" {
  assert_eq(render("{{#count}}zero{{/count}}", { "count": 0.0 }), "zero")
}

///|
test "compatibility treats false, null and empty string as falsey" {
  let data : Json = { "a": false, "b": null, "c": "" }
  assert_eq(render("{{^a}}A{{/a}}{{^b}}B{{/b}}{{^c}}C{{/c}}", data), "ABC")
}

///|
test "compatibility treats empty object as a section context" {
  assert_eq(render("{{#object}}shown{{/object}}", { "object": {} }), "shown")
}

///|
test "compatibility iterates mixed json arrays deterministically" {
  let data : Json = { "items": ["text", 0.0, false, { "name": "object" }] }
  assert_eq(
    render("{{#items}}[{{.}}]{{/items}}", data),
    "[text][0][false][[Object]]",
  )
}

///|
test "compatibility keeps CRLF text around a section" {
  let data : Json = { "ok": true }
  assert_eq(
    render("before\r\n{{#ok}}inside\r\n{{/ok}}\r\nafter", data),
    "before\r\ninside\r\nafter",
  )
}

///|
test "compatibility ignores inline comments without changing surrounding text" {
  assert_eq(render("left {{! inline }} right", {}), "left  right")
}

///|
test "compatibility removes standalone inverted control lines" {
  let data : Json = { "items": [] }
  assert_eq(render("A\n{{^items}}\nempty\n{{/items}}\nB", data), "A\nempty\nB")
}

///|
test "compatibility preserves inline partial placement" {
  assert_eq(render_with_partials("A{{>x}}B", {}, { "x": "X" }), "AXB")
}

///|
test "compatibility applies partial indentation to every LF line" {
  let result = render_with_partials("root:\n\t{{>block}}", {}, {
    "block": "one\ntwo\nthree",
  })
  assert_eq(result, "root:\n\tone\n\ttwo\n\tthree")
}

///|
test "compatibility keeps partial trailing newline" {
  let result = render_with_partials("{{>block}}", {}, { "block": "one\ntwo\n" })
  assert_eq(result, "one\ntwo\n")
}

///|
test "compatibility ignores malformed optional partial source" {
  let result = render_with_partials("A{{>broken}}B", {}, {
    "broken": "{{#missing}}",
  })
  assert_eq(result, "AB")
}

///|
test "compatibility reports an unclosed tag with source index" {
  try {
    ignore(render("prefix {{value", {}))
    fail("expected unclosed tag error")
  } catch {
    TemplateError(msg) => assert_eq(msg, "unclosed tag at index 7")
    _ => fail("expected TemplateError")
  }
}

///|
test "compatibility reports an unexpected close" {
  try {
    ignore(render("{{/unexpected}}", {}))
    fail("expected unexpected close error")
  } catch {
    TemplateError(msg) => assert_eq(msg, "unexpected closing tag: unexpected")
    _ => fail("expected TemplateError")
  }
}

///|
test "compatibility reports a mismatched close" {
  try {
    ignore(render("{{#one}}{{/two}}", {}))
    fail("expected mismatched close error")
  } catch {
    TemplateError(msg) =>
      assert_eq(msg, "section close mismatch: expected one, got two")
    _ => fail("expected TemplateError")
  }
}

///|
test "compatibility renders repeated compiled template deterministically" {
  let template = compile("{{#items}}{{name}};{{/items}}")
  let data : Json = {
    "items": [{ "name": "a" }, { "name": "b" }, { "name": "c" }],
  }
  for i = 0; i < 10; i = i + 1 {
    assert_eq(template.render(data), "a;b;c;")
  }
}
