// parser white-box tests

///|
test "parse simple text" {
  let tokens = [Text("hello")]
  let nodes = parse(tokens)
  assert_eq(nodes.length(), 1)
  assert_eq(nodes[0], TextNode("hello"))
}

///|
test "parse variable" {
  let tokens = [Text("hi "), Variable("name")]
  let nodes = parse(tokens)
  assert_eq(nodes.length(), 2)
  assert_eq(nodes[0], TextNode("hi "))
  assert_eq(nodes[1], VarNode("name", true))
}

///|
test "parse raw variable" {
  let tokens = [RawVariable("html")]
  let nodes = parse(tokens)
  assert_eq(nodes.length(), 1)
  assert_eq(nodes[0], VarNode("html", false))
}

///|
test "parse section" {
  let tokens = [SectionOpen("show"), Text("content"), SectionClose("show")]
  let nodes = parse(tokens)
  assert_eq(nodes.length(), 1)
  match nodes[0] {
    SectionNode(name, children, inverted) => {
      assert_eq(name, "show")
      assert_eq(children.length(), 1)
      assert_eq(inverted, false)
    }
    _ => fail("should be SectionNode")
  }
}

///|
test "parse inverted section" {
  let tokens = [InvertedOpen("empty"), Text("nothing"), SectionClose("empty")]
  let nodes = parse(tokens)
  assert_eq(nodes.length(), 1)
  match nodes[0] {
    SectionNode(name, _, inverted) => {
      assert_eq(name, "empty")
      assert_eq(inverted, true)
    }
    _ => fail("should be inverted SectionNode")
  }
}

///|
test "parse nested sections" {
  let tokens = [
    SectionOpen("a"),
    Text("outer"),
    SectionOpen("b"),
    Text("inner"),
    SectionClose("b"),
    SectionClose("a"),
  ]
  let nodes = parse(tokens)
  assert_eq(nodes.length(), 1)
  match nodes[0] {
    SectionNode(name, children, _) => {
      assert_eq(name, "a")
      assert_eq(children.length(), 2)
    }
    _ => fail("should be SectionNode")
  }
}

///|
test "parse comment ignored" {
  let tokens = [Text("a"), Comment("ignored"), Text("b")]
  let nodes = parse(tokens)
  assert_eq(nodes.length(), 2)
  assert_eq(nodes[0], TextNode("a"))
  assert_eq(nodes[1], TextNode("b"))
}

///|
test "parse partial captures standalone indentation" {
  let tokens = [Text("items:\n  "), Partial("item"), Text("\ndone")]
  let nodes = parse(tokens)
  assert_eq(nodes.length(), 3)
  assert_eq(nodes[0], TextNode("items:\n"))
  assert_eq(nodes[1], PartialNode("item", "  "))
  assert_eq(nodes[2], TextNode("\ndone"))
}

///|
test "parse unexpected close raises error" {
  try {
    ignore(parse([SectionClose("oops")]))
    fail("expected parse to fail")
  } catch {
    TemplateError(msg) => assert_eq(msg, "unexpected closing tag: oops")
    _ => fail("expected TemplateError")
  }
}

///|
test "parse mismatched close raises error" {
  try {
    ignore(parse([SectionOpen("a"), SectionClose("b")]))
    fail("expected parse to fail")
  } catch {
    TemplateError(msg) =>
      assert_eq(msg, "section close mismatch: expected a, got b")
    _ => fail("expected TemplateError")
  }
}

///|
test "parse rejects excessive nesting depth" {
  let tokens : Array[Token] = []
  for i = 0; i < 257; i = i + 1 {
    tokens.push(SectionOpen("level"))
  }
  for i = 0; i < 257; i = i + 1 {
    tokens.push(SectionClose("level"))
  }
  try {
    ignore(parse(tokens))
    fail("expected parse to reject excessive nesting")
  } catch {
    TemplateError(msg) =>
      assert_eq(msg, "maximum section nesting depth exceeded")
    _ => fail("expected TemplateError")
  }
}
