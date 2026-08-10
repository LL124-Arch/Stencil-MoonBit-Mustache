///|
/// Build the template AST from the scanned token stream.
pub fn parse(tokens : Array[Token]) -> Array[Node] raise TemplateError {
  let result = parse_inner(tokens, 0, "", 0)
  result.0
}

///|
/// Recursively parse nested sections until `until` is closed.
fn parse_inner(
  tokens : Array[Token],
  start : Int,
  until : String,
  depth : Int,
) -> (Array[Node], Int) raise TemplateError {
  if depth > 256 {
    raise TemplateError("maximum section nesting depth exceeded")
  }
  let nodes : Array[Node] = []
  let mut i = start
  while i < tokens.length() {
    let tok = tokens[i]
    match tok {
      Text(s) => {
        nodes.push(TextNode(s))
        i = i + 1
      }
      Variable(name) => {
        nodes.push(VarNode(name, true))
        i = i + 1
      }
      RawVariable(name) => {
        nodes.push(VarNode(name, false))
        i = i + 1
      }
      Comment(_) => i = i + 1
      Partial(name) => {
        nodes.push(PartialNode(name, take_partial_indent(nodes)))
        i = i + 1
      }
      SectionOpen(name) => {
        let inner = parse_inner(tokens, i + 1, name, depth + 1)
        let children = inner.0
        let consumed = inner.1
        nodes.push(SectionNode(name, children, false))
        i = i + 1 + consumed
      }
      InvertedOpen(name) => {
        let inner = parse_inner(tokens, i + 1, name, depth + 1)
        let children = inner.0
        let consumed = inner.1
        nodes.push(SectionNode(name, children, true))
        i = i + 1 + consumed
      }
      SectionClose(name) => {
        if until.length() == 0 {
          raise TemplateError("unexpected closing tag: \{name}")
        }
        if name != until {
          raise TemplateError(
            "section close mismatch: expected \{until}, got \{name}",
          )
        }
        return (nodes, i - start + 1)
      }
    }
  }
  if until.length() > 0 {
    raise TemplateError("unclosed section: \{until}")
  }
  (nodes, i - start)
}

///|
/// Standalone partials inherit indentation from the previous line prefix.
fn take_partial_indent(nodes : Array[Node]) -> String {
  if nodes.length() == 0 {
    return ""
  }
  let last = nodes[nodes.length() - 1]
  match last {
    TextNode(text) => {
      let indent = trailing_line_indent(text)
      if indent.length() == 0 {
        return ""
      }
      let kept = substring(text, 0, text.length() - indent.length())
      if kept.length() == 0 {
        let _ = nodes.pop()
      } else {
        nodes[nodes.length() - 1] = TextNode(kept)
      }
      indent
    }
    _ => ""
  }
}

///|
/// Return the whitespace suffix that forms the indentation of the current line.
fn trailing_line_indent(text : String) -> String {
  if text.length() == 0 {
    return ""
  }
  let mut line_start = 0
  let mut i = text.length() - 1
  while i >= 0 {
    let ch = char_at(text, i)
    if ch == '\n' || ch == '\r' {
      line_start = i + 1
      break
    }
    if i == 0 {
      line_start = 0
      break
    }
    i = i - 1
  }
  let suffix = substring(text, line_start, text.length())
  if suffix.length() == 0 {
    return ""
  }
  let mut only_indent = true
  for idx = 0; idx < suffix.length(); idx = idx + 1 {
    let ch = char_at(suffix, idx)
    if ch != ' ' && ch != '\t' {
      only_indent = false
      break
    }
  }
  if !only_indent {
    return ""
  }
  if line_start == 0 && suffix.length() != text.length() {
    return ""
  }
  suffix
}
