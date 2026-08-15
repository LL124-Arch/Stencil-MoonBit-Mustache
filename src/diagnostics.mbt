/// Structured diagnostics and source-independent template metrics.

///|
/// Diagnostic severity used by static template inspection.
pub(all) enum DiagnosticSeverity {
  Error
  Warning
  Info
} derive(Debug, Eq)

///|
/// A source location using one-based line and column numbers.
pub(all) struct TemplatePosition {
  index : Int
  line : Int
  column : Int
} derive(Debug, Eq)

///|
/// A deterministic message produced by template inspection.
pub(all) struct TemplateDiagnostic {
  severity : DiagnosticSeverity
  message : String
  index : Int
  line : Int
  column : Int
} derive(Debug, Eq)

///|
/// Structural information useful to editors, CLIs, and cache planners.
pub(all) struct TemplateStats {
  node_count : Int
  text_node_count : Int
  variable_count : Int
  raw_variable_count : Int
  section_count : Int
  inverted_section_count : Int
  partial_count : Int
  max_depth : Int
  has_custom_delimiters : Bool
} derive(Debug, Eq)

///|
fn empty_stats() -> TemplateStats {
  {
    node_count: 0,
    text_node_count: 0,
    variable_count: 0,
    raw_variable_count: 0,
    section_count: 0,
    inverted_section_count: 0,
    partial_count: 0,
    max_depth: 0,
    has_custom_delimiters: false,
  }
}

///|
fn position_at(source : String, index : Int) -> TemplatePosition {
  let safe_index = if index < 0 {
    -1
  } else if index > source.length() {
    source.length()
  } else {
    index
  }
  let mut line = 1
  let mut column = 1
  let mut i = 0
  while i < safe_index {
    if char_at(source, i) == '\n' {
      line += 1
      column = 1
    } else {
      column += 1
    }
    i += 1
  }
  { index: safe_index, line, column }
}

///|
fn index_from_error(message : String) -> Int {
  let marker = " at index "
  let start = find_str(message, marker, 0)
  if start >= 0 {
    parse_decimal(substring(message, start + marker.length(), message.length()))
  } else {
    -1
  }
}

///|
fn parse_decimal(text : String) -> Int {
  let mut result = 0
  for i = 0; i < text.length(); i = i + 1 {
    let digit = char_at(text, i)
    if digit < '0' || digit > '9' {
      break
    }
    result = result * 10 + (digit.to_int() - '0'.to_int())
  }
  result
}

///|
/// Return compile diagnostics without raising, making malformed user input safe for tooling.
pub fn diagnose(source : String) -> Array[TemplateDiagnostic] {
  try {
    ignore(compile(source))
    []
  } catch {
    TemplateError(message) => {
      let parsed_index = index_from_error(message)
      let index = if parsed_index >= 0 {
        parsed_index
      } else {
        let closing = find_str(source, "{{/", 0)
        if closing >= 0 {
          closing
        } else {
          let opening = find_str(source, "{{#", 0)
          if opening >= 0 {
            opening
          } else {
            0
          }
        }
      }
      let position = position_at(source, index)
      [
        {
          severity: DiagnosticSeverity::Error,
          message,
          index: position.index,
          line: position.line,
          column: position.column,
        },
      ]
    }
  }
}
