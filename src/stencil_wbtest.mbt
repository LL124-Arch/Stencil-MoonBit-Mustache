// rendering and public API integration tests

///|
test "render simple variable" {
  let result = render("Hello {{name}}!", { "name": "World" })
  assert_eq(result, "Hello World!")
}

///|
test "render html escape by default" {
  let result = render("{{content}}", { "content": "<b>bold</b>" })
  assert_eq(result, "&lt;b&gt;bold&lt;/b&gt;")
}

///|
test "render raw variable no escape" {
  let result = render("{{{content}}}", { "content": "<b>bold</b>" })
  assert_eq(result, "<b>bold</b>")
}

///|
test "render section true" {
  let result = render("{{#show}}visible{{/show}}", { "show": true })
  assert_eq(result, "visible")
}

///|
test "render section false" {
  let result = render("{{#show}}visible{{/show}}", { "show": false })
  assert_eq(result, "")
}

///|
test "render inverted section" {
  let result = render("{{^list}}empty{{/list}}", { "list": [] })
  assert_eq(result, "empty")
}

///|
test "render list iteration" {
  let data : Json = { "items": [{ "name": "apple" }, { "name": "banana" }] }
  let result = render("{{#items}}{{name}} {{/items}}", data)
  assert_eq(result, "apple banana ")
}

///|
test "render dot notation" {
  let data : Json = { "person": { "name": "Alice" } }
  let result = render("Hi {{person.name}}", data)
  assert_eq(result, "Hi Alice")
}

///|
test "render implicit iterator" {
  let data : Json = { "tags": ["a", "b", "c"] }
  let result = render("{{#tags}}[{{.}}]{{/tags}}", data)
  assert_eq(result, "[a][b][c]")
}

///|
test "render missing variable" {
  let result = render("Hello {{name}}!", {})
  assert_eq(result, "Hello !")
}

///|
test "render number" {
  let result = render("count: {{n}}", { "n": 42.0 })
  assert_eq(result, "count: 42")
}

///|
test "render nested section" {
  let data : Json = { "a": true }
  let result = render("{{#a}}yes{{/a}}", data)
  assert_eq(result, "yes")
}

///|
test "render comment stripped" {
  let result = render("before{{! this is a comment }}after", {})
  assert_eq(result, "beforeafter")
}

///|
test "compile and reuse" {
  let tpl = compile("Hello {{name}}!")
  let r1 = tpl.render({ "name": "A" })
  let r2 = tpl.render({ "name": "B" })
  assert_eq(r1, "Hello A!")
  assert_eq(r2, "Hello B!")
}

///|
test "render deeply nested sections" {
  let data : Json = { "a": { "b": { "c": { "d": "deep" } } } }
  let result = render("{{#a}}{{#b}}{{#c}}{{d}}{{/c}}{{/b}}{{/a}}", data)
  assert_eq(result, "deep")
}

///|
test "render extreme falsey values" {
  let data : Json = {
    "empty_str": "",
    "zero": 0.0,
    "false_val": false,
    "empty_array": [],
  }
  let r1 = render("{{empty_str}}", data)
  assert_eq(r1, "")
  let r2 = render("{{zero}}", data)
  assert_eq(r2, "0")
  let r4 = render("{{^false_val}}f{{/false_val}}", data)
  assert_eq(r4, "f")
  let r5 = render("{{^empty_array}}e{{/empty_array}}", data)
  assert_eq(r5, "e")
}

///|
test "render partial with indentation" {
  let partials = { "item": "- {{name}}\n- ready" }
  let data : Json = { "name": "Alice" }
  let result = render_with_partials("items:\n  {{>item}}\ndone", data, partials)
  assert_eq(result, "items:\n  - Alice\n  - ready\ndone")
}

///|
test "render inline partial without extra indentation" {
  let partials = { "name": "MoonBit" }
  let result = render_with_partials("Hello {{>name}}!", {}, partials)
  assert_eq(result, "Hello MoonBit!")
}

///|
test "render missing partial as empty string" {
  let result = render_with_partials("A{{>missing}}B", {}, {})
  assert_eq(result, "AB")
}

///|
test "render object string values in nested section" {
  let data : Json = { "user": { "profile": { "name": "Stencil" } } }
  let result = render("{{#user}}{{profile.name}}{{/user}}", data)
  assert_eq(result, "Stencil")
}
