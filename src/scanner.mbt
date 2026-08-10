///|
/// Convert a template string into a token stream.
pub fn scan(input : String) -> Array[Token] raise TemplateError {
  let tokens : Array[Token] = []
  let input = normalize_standalone_controls(input)
  let len = input.length()
  let mut open = "{{"
  let mut closing = "}}"
  let mut pos = 0
  while pos < len {
    let tag_start = find_str(input, open, pos)
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
    let is_triple = open == "{{" &&
      tag_start + 2 < len &&
      char_at(input, tag_start + 2) == '{'
    let content_start = if is_triple {
      tag_start + 3
    } else {
      tag_start + open.length()
    }
    let tag_close = if is_triple { "}}}" } else { closing }
    let tag_end = find_str(input, tag_close, content_start)
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
      if sigil == '=' && char_at(content, content.length() - 1) == '=' {
        let spec = trim_spaces(substring(content, 1, content.length() - 1))
        let parts = split_by_char(spec, ' ')
        let delimiters : Array[String] = []
        for part in parts {
          if part.length() > 0 {
            delimiters.push(part)
          }
        }
        if delimiters.length() != 2 {
          raise TemplateError("invalid delimiter declaration")
        }
        open = delimiters[0]
        closing = delimiters[1]
      } else {
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
      }
      pos = tag_end + tag_close.length()
    } else {
      tokens.push(Variable(""))
      pos = tag_end + tag_close.length()
    }
  }
  tokens
}

///|
/// Remove standalone comment and section-control lines before tokenization.
/// Partial lines are intentionally preserved because the parser uses their
/// leading whitespace to implement indentation propagation.
fn normalize_standalone_controls(input : String) -> String {
  let buf = StringBuilder::new()
  let mut line_start = 0
  let mut i = 0
  while i < input.length() {
    if char_at(input, i) == '\n' {
      let line_end = if i > line_start && char_at(input, i - 1) == '\r' {
        i - 1
      } else {
        i
      }
      let line = substring(input, line_start, line_end)
      let kind = standalone_control_kind(line)
      if kind == 1 {
        ()
      } else if kind == 2 {
        buf.write_string(trim_spaces(line))
      } else {
        buf.write_string(substring(input, line_start, i + 1))
      }
      line_start = i + 1
    }
    i = i + 1
  }
  if line_start < input.length() {
    let line = substring(input, line_start, input.length())
    let kind = standalone_control_kind(line)
    if kind == 1 {
      ()
    } else if kind == 2 {
      buf.write_string(trim_spaces(line))
    } else {
      buf.write_string(line)
    }
  }
  buf.to_string()
}

///|
/// Classify a standalone line: 1 comment, 2 section control, 0 other.
fn standalone_control_kind(line : String) -> Int {
  let trimmed = trim_spaces(line)
  if trimmed.length() < 4 || substring(trimmed, 0, 2) != "{{" {
    return 0
  }
  let close = find_str(trimmed, "}}", 2)
  if close != trimmed.length() - 2 {
    return 0
  }
  let content = trim_spaces(substring(trimmed, 2, close))
  if content.length() == 0 {
    return 0
  }
  match char_at(content, 0) {
    '!' => 1
    '#' => 2
    '^' => 2
    '/' => 2
    '=' => if char_at(content, content.length() - 1) == '=' { 2 } else { 0 }
    _ => 0
  }
}
