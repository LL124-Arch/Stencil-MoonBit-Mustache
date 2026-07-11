// scanner white-box tests

///|
test "scan plain text" {
  let tokens = scan("hello world")
  assert_eq(tokens.length(), 1)
  assert_eq(tokens[0], Text("hello world"))
}

///|
test "scan variable" {
  let tokens = scan("hello {{name}}")
  assert_eq(tokens.length(), 2)
  assert_eq(tokens[0], Text("hello "))
  assert_eq(tokens[1], Variable("name"))
}

///|
test "scan raw variable triple" {
  let tokens = scan("{{{html}}}")
  assert_eq(tokens.length(), 1)
  assert_eq(tokens[0], RawVariable("html"))
}

///|
test "scan raw variable ampersand" {
  let tokens = scan("{{&html}}")
  assert_eq(tokens.length(), 1)
  assert_eq(tokens[0], RawVariable("html"))
}

///|
test "scan section" {
  let tokens = scan("{{#show}}content{{/show}}")
  assert_eq(tokens.length(), 3)
  assert_eq(tokens[0], SectionOpen("show"))
  assert_eq(tokens[1], Text("content"))
  assert_eq(tokens[2], SectionClose("show"))
}

///|
test "scan inverted section" {
  let tokens = scan("{{^empty}}fallback{{/empty}}")
  assert_eq(tokens.length(), 3)
  assert_eq(tokens[0], InvertedOpen("empty"))
  assert_eq(tokens[1], Text("fallback"))
  assert_eq(tokens[2], SectionClose("empty"))
}

///|
test "scan comment" {
  let tokens = scan("before{{! this is ignored }}after")
  assert_eq(tokens.length(), 3)
  assert_eq(tokens[0], Text("before"))
  assert_eq(tokens[1], Comment("this is ignored"))
  assert_eq(tokens[2], Text("after"))
}

///|
test "scan partial" {
  let tokens = scan("{{>header}}")
  assert_eq(tokens.length(), 1)
  assert_eq(tokens[0], Partial("header"))
}

///|
test "scan mixed" {
  let tokens = scan("Hi {{name}}, you have {{count}} items.")
  assert_eq(tokens.length(), 5)
  assert_eq(tokens[0], Text("Hi "))
  assert_eq(tokens[1], Variable("name"))
  assert_eq(tokens[2], Text(", you have "))
  assert_eq(tokens[3], Variable("count"))
  assert_eq(tokens[4], Text(" items."))
}

///|
test "scan trims inner whitespace" {
  let tokens = scan("{{  name  }}")
  assert_eq(tokens.length(), 1)
  assert_eq(tokens[0], Variable("name"))
}

///|
test "scan unclosed tag raises error" {
  try {
    ignore(scan("hello {{name"))
    fail("expected scan to fail")
  } catch {
    TemplateError(msg) => assert_eq(msg, "unclosed tag at index 6")
    _ => fail("expected TemplateError")
  }
}
