// Deterministic size, depth and input-boundary tests.

///|
fn repeated_text(text : String, count : Int) -> String {
  let buf = StringBuilder::new()
  for i = 0; i < count; i = i + 1 {
    buf.write_string(text)
  }
  buf.to_string()
}

///|
fn nested_template(depth : Int) -> String {
  let buf = StringBuilder::new()
  for i = 0; i < depth; i = i + 1 {
    buf.write_string("{{#level}}")
  }
  buf.write_string("{{value}}")
  for i = 0; i < depth; i = i + 1 {
    buf.write_string("{{/level}}")
  }
  buf.to_string()
}

///|
fn nested_data(depth : Int) -> Json {
  let mut current : Json = { "value": "deep" }
  for i = 0; i < depth; i = i + 1 {
    current = { "level": current }
  }
  current
}

///|
fn indexed_data(count : Int) -> Json {
  let items : Array[Json] = []
  for i = 0; i < count; i = i + 1 {
    items.push({ "index": i.to_string() })
  }
  { "items": Json::array(items) }
}

///|
test "stress accepts one nested section" {
  assert_eq(render(nested_template(1), nested_data(1)), "deep")
}

///|
test "stress accepts eight nested sections" {
  assert_eq(render(nested_template(8), nested_data(8)), "deep")
}

///|
test "stress accepts thirty two nested sections" {
  assert_eq(render(nested_template(32), nested_data(32)), "deep")
}

///|
test "stress accepts one hundred twenty eight nested sections" {
  assert_eq(render(nested_template(128), nested_data(128)), "deep")
}

///|
test "stress accepts parser depth boundary" {
  assert_eq(render(nested_template(256), nested_data(256)), "deep")
}

///|
test "stress renders empty input" {
  assert_eq(render("", Json::empty_object()), "")
}

///|
test "stress renders one character input" {
  assert_eq(render("x", Json::empty_object()), "x")
}

///|
test "stress renders a four kilobyte text block" {
  let text = repeated_text("abcd", 1024)
  assert_eq(render(text, Json::empty_object()).length(), 4096)
}

///|
test "stress renders a sixteen kilobyte text block" {
  let text = repeated_text("0123456789abcdef", 1024)
  assert_eq(render(text, Json::empty_object()).length(), 16384)
}

///|
test "stress renders a long interpolated string" {
  let value = repeated_text("MoonBit", 512)
  assert_eq(render("{{value}}", { "value": value }), value)
}

///|
test "stress escapes a long interpolated string" {
  let value = repeated_text("<&", 512)
  let output = render("{{value}}", { "value": value })
  assert_eq(output, repeated_text("&lt;&amp;", 512))
}

///|
test "stress renders an empty list" {
  assert_eq(render("{{#items}}x{{/items}}", indexed_data(0)), "")
}

///|
test "stress renders a one item list" {
  assert_eq(render("{{#items}}{{index}}{{/items}}", indexed_data(1)), "0")
}

///|
test "stress renders an eight item list" {
  assert_eq(
    render("{{#items}}{{index}},{{/items}}", indexed_data(8)),
    "0,1,2,3,4,5,6,7,",
  )
}

///|
test "stress renders a sixty four item list" {
  let output = render("{{#items}}x{{/items}}", indexed_data(64))
  assert_eq(output.length(), 64)
}

///|
test "stress renders a two hundred fifty six item list" {
  let output = render("{{#items}}x{{/items}}", indexed_data(256))
  assert_eq(output.length(), 256)
}

///|
test "stress keeps repeated compiled rendering stable" {
  let template = compile("{{#items}}{{index}};{{/items}}")
  let data = indexed_data(32)
  for i = 0; i < 32; i = i + 1 {
    assert_eq(template.render(data).length(), 86)
  }
}

///|
test "stress handles nested sections with a missing leaf" {
  let data : Json = { "level": { "level": { "other": true } } }
  assert_eq(
    render("{{#level}}{{#level}}{{value}}{{/level}}{{/level}}", data),
    "",
  )
}

///|
test "stress handles nested sections with false leaf" {
  let data : Json = { "level": { "level": false } }
  assert_eq(render("{{#level}}{{#level}}bad{{/level}}{{/level}}", data), "")
}

///|
test "stress preserves CRLF in long text" {
  let text = repeated_text("line\r\n", 128)
  assert_eq(render(text, Json::empty_object()), text)
}

///|
test "stress preserves LF in long text" {
  let text = repeated_text("line\n", 128)
  assert_eq(render(text, Json::empty_object()), text)
}

///|
test "stress renders mixed scalar values" {
  let data : Json = {
    "a": "text",
    "b": true,
    "c": false,
    "d": 0.0,
    "e": 3.5,
    "f": null,
  }
  assert_eq(
    render("{{a}}|{{b}}|{{c}}|{{d}}|{{e}}|{{f}}", data),
    "text|true|false|0|3.5|",
  )
}

///|
test "stress keeps raw output unescaped at large size" {
  let value = repeated_text("<raw>&", 256)
  assert_eq(render("{{{value}}}", { "value": value }), value)
}

///|
test "stress keeps missing partial lookup bounded" {
  let partials : Map[String, String] = Map([])
  assert_eq(
    render_with_partials("before{{>none}}after", Json::empty_object(), partials),
    "beforeafter",
  )
}

///|
test "stress applies indentation to a long partial" {
  let partial = repeated_text("x\ny\n", 32)
  let output = render_with_partials("\t{{>block}}", Json::empty_object(), {
    "block": partial,
  })
  assert_eq(output, repeated_text("\tx\n\ty\n", 32))
}

///|
test "stress handles nested dotted lookup" {
  let data : Json = { "a": { "b": { "c": { "d": { "value": "ok" } } } } }
  assert_eq(render("{{a.b.c.d.value}}", data), "ok")
}

///|
test "stress handles missing intermediate dotted lookup" {
  let data : Json = { "a": { "b": false } }
  assert_eq(render("{{a.b.c.d}}", data), "")
}

///|
test "stress keeps standalone control line output bounded" {
  let template = repeated_text("{{#ok}}\nvalue\n{{/ok}}\n", 64)
  let output = render(template, { "ok": true })
  assert_eq(output, repeated_text("value\n", 64))
}
