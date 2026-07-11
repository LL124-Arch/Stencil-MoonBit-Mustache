///|
/// Convert a template string into a token stream.
pub fn scan(input : String) -> Array[Token] raise TemplateError {
  let tokens : Array[Token] = []
  let len = input.length()
  let mut pos = 0
  while pos < len {
    let tag_start = find_str(input, "{{", pos)
    if tag_start < 0 {
      let rest = substring_from(input, pos)
      if rest.length() > 0 {
        tokens.push(Text(rest))
      }
      break
    }
    if tag_start > pos {
      tokens.push(Text(substring(input, pos, tag_start)))
    }
    let is_triple = tag_start + 2 < len && char_at(input, tag_start + 2) == '{'
    let content_start = if is_triple { tag_start + 3 } else { tag_start + 2 }
    let close = if is_triple { "}}}" } else { "}}" }
    let tag_end = find_str(input, close, content_start)
    if tag_end < 0 {
      raise TemplateError("unclosed tag at index \{tag_start}")
    }
    let raw = substring(input, content_start, tag_end)
    let content = trim_spaces(raw)
    if is_triple {
      tokens.push(RawVariable(content))
      pos = tag_end + 3
    } else if content.length() > 0 {
      let sigil = char_at(content, 0)
      let name = trim_spaces(substring_from(content, 1))
      match sigil {
        '#' => tokens.push(SectionOpen(name))
        '/' => tokens.push(SectionClose(name))
        '^' => tokens.push(InvertedOpen(name))
        '>' => tokens.push(Partial(name))
        '!' => tokens.push(Comment(name))
        '&' => tokens.push(RawVariable(name))
        _ => tokens.push(Variable(content))
      }
      pos = tag_end + 2
    } else {
      tokens.push(Variable(""))
      pos = tag_end + 2
    }
  }
  tokens
}
