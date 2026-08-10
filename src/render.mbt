///|
/// Render an AST with a context stack and optional partial templates.
///
/// This compatibility entry point keeps the historical non-raising signature.
/// Checked public APIs use `render_nodes_checked` so malformed expansion depth
/// is reported as a TemplateError instead of causing unbounded recursion.
pub fn render_nodes(
  nodes : Array[Node],
  ctx : Context,
  partials : Map[String, Array[Node]],
) -> String {
  render_nodes_checked(nodes, ctx, partials, 0) catch {
    _ => ""
  }
}

///|
/// Render nodes while preserving depth errors for checked entry points.
fn render_nodes_checked(
  nodes : Array[Node],
  ctx : Context,
  partials : Map[String, Array[Node]],
  depth : Int,
) -> String raise TemplateError {
  let buf = StringBuilder::new()
  let mut i = 0
  while i < nodes.length() {
    let node = nodes[i]
    match node {
      TextNode(text) => buf.write_string(text)
      VarNode(name, escaped) => {
        let val = ctx.find(name)
        let text = value_to_string(val)
        if escaped {
          buf.write_string(escape_html(text))
        } else {
          buf.write_string(text)
        }
      }
      SectionNode(name, children, inverted) =>
        buf.write_string(
          render_section_checked(name, children, inverted, ctx, partials, depth),
        )
      PartialNode(name, indent) =>
        buf.write_string(
          render_partial_checked(name, indent, ctx, partials, depth),
        )
    }
    i = i + 1
  }
  buf.to_string()
}

///|
/// Render a section with bounded recursive expansion.
fn render_section_checked(
  name : String,
  children : Array[Node],
  inverted : Bool,
  ctx : Context,
  partials : Map[String, Array[Node]],
  depth : Int,
) -> String raise TemplateError {
  if depth > 256 {
    raise TemplateError("maximum render nesting depth exceeded")
  }
  let val = ctx.find(name)
  if inverted {
    if is_truthy(val) {
      return ""
    }
    return render_nodes_checked(children, ctx, partials, depth + 1)
  }
  match val {
    Null => ""
    False => ""
    True => render_nodes_checked(children, ctx, partials, depth + 1)
    Array(items) => {
      if items.length() == 0 {
        return ""
      }
      let buf = StringBuilder::new()
      let mut idx = 0
      while idx < items.length() {
        ctx.push(items[idx])
        buf.write_string(
          render_nodes_checked(children, ctx, partials, depth + 1),
        )
        ctx.pop()
        idx = idx + 1
      }
      buf.to_string()
    }
    Object(_) => {
      ctx.push(val)
      let result = render_nodes_checked(children, ctx, partials, depth + 1)
      ctx.pop()
      result
    }
    String(s) =>
      if s.length() == 0 {
        ""
      } else {
        render_nodes_checked(children, ctx, partials, depth + 1)
      }
    Number(_, ..) => render_nodes_checked(children, ctx, partials, depth + 1)
  }
}

///|
/// Render a partial while bounding recursive expansion.
fn render_partial_checked(
  name : String,
  indent : String,
  ctx : Context,
  partials : Map[String, Array[Node]],
  depth : Int,
) -> String raise TemplateError {
  if depth >= 256 {
    raise TemplateError("maximum partial nesting depth exceeded")
  }
  match partials.get(name) {
    Some(nodes) => {
      let content = render_nodes_checked(nodes, ctx, partials, depth + 1)
      if indent.length() > 0 {
        let buf = StringBuilder::new()
        buf.write_string(indent)
        for i = 0; i < content.length(); i = i + 1 {
          let ch = char_at(content, i)
          buf.write_char(ch)
          if ch == '\n' && i < content.length() - 1 {
            buf.write_string(indent)
          }
        }
        buf.to_string()
      } else {
        content
      }
    }
    None => ""
  }
}
