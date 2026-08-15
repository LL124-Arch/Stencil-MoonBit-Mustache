/// Rendering engine with explicit resource and compatibility policies.

///|
/// Historical non-raising entry point. New applications should use checked APIs.
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
fn render_nodes_checked(
  nodes : Array[Node],
  ctx : Context,
  partials : Map[String, Array[Node]],
  depth : Int,
) -> String raise TemplateError {
  render_nodes_with_options(
    nodes,
    ctx,
    partials,
    RenderOptions::default(),
    depth,
    [],
  )
}

///|
fn render_nodes_with_options(
  nodes : Array[Node],
  ctx : Context,
  partials : Map[String, Array[Node]],
  options : RenderOptions,
  depth : Int,
  active_partials : Array[String],
) -> String raise TemplateError {
  enforce_nesting_limit(options, depth)
  let buf = StringBuilder::new()
  let mut i = 0
  while i < nodes.length() {
    match nodes[i] {
      TextNode(text) => buf.write_string(text)
      VarNode(name, escaped) => {
        let text = value_to_string(ctx.find(name))
        if escaped && options.escape_html() {
          buf.write_string(escape_html(text))
        } else {
          buf.write_string(text)
        }
      }
      SectionNode(name, children, inverted) =>
        buf.write_string(
          render_section_with_options(
            name, children, inverted, ctx, partials, options, depth, active_partials,
          ),
        )
      PartialNode(name, indent) =>
        buf.write_string(
          render_partial_with_options(
            name, indent, ctx, partials, options, depth, active_partials,
          ),
        )
    }
    i += 1
  }
  let output = buf.to_string()
  enforce_output_limit(options, output)
  output
}

///|
fn render_section_with_options(
  name : String,
  children : Array[Node],
  inverted : Bool,
  ctx : Context,
  partials : Map[String, Array[Node]],
  options : RenderOptions,
  depth : Int,
  active_partials : Array[String],
) -> String raise TemplateError {
  enforce_nesting_limit(options, depth)
  let val = ctx.find(name)
  if inverted {
    if is_truthy(val) {
      return ""
    }
    return render_nodes_with_options(
      children,
      ctx,
      partials,
      options,
      depth + 1,
      active_partials,
    )
  }
  match val {
    Null => ""
    False => ""
    True =>
      render_nodes_with_options(
        children,
        ctx,
        partials,
        options,
        depth + 1,
        active_partials,
      )
    Array(items) => {
      if items.length() == 0 {
        return ""
      }
      let buf = StringBuilder::new()
      let mut idx = 0
      while idx < items.length() {
        ctx.push(items[idx])
        buf.write_string(
          render_nodes_with_options(
            children,
            ctx,
            partials,
            options,
            depth + 1,
            active_partials,
          ),
        )
        ctx.pop()
        idx += 1
      }
      let output = buf.to_string()
      enforce_output_limit(options, output)
      output
    }
    Object(_) => {
      ctx.push(val)
      let result = render_nodes_with_options(
        children,
        ctx,
        partials,
        options,
        depth + 1,
        active_partials,
      )
      ctx.pop()
      result
    }
    String(s) =>
      if s.length() == 0 {
        ""
      } else {
        render_nodes_with_options(
          children,
          ctx,
          partials,
          options,
          depth + 1,
          active_partials,
        )
      }
    Number(_, ..) =>
      render_nodes_with_options(
        children,
        ctx,
        partials,
        options,
        depth + 1,
        active_partials,
      )
  }
}

///|
fn render_partial_with_options(
  name : String,
  indent : String,
  ctx : Context,
  partials : Map[String, Array[Node]],
  options : RenderOptions,
  depth : Int,
  active_partials : Array[String],
) -> String raise TemplateError {
  if options.detect_partial_cycles() && array_contains(active_partials, name) {
    raise TemplateError("partial cycle detected: \{name}")
  }
  if options.max_partial_depth() > 0 && depth >= options.max_partial_depth() {
    raise TemplateError("maximum partial nesting depth exceeded")
  }
  match partials.get(name) {
    Some(nodes) => {
      let content = render_nodes_with_options(
        nodes,
        ctx,
        partials,
        options,
        depth + 1,
        array_append(active_partials, name),
      )
      let output = apply_partial_indent(content, indent)
      enforce_output_limit(options, output)
      output
    }
    None =>
      match options.missing_partial() {
        MissingPartialPolicy::Empty => ""
        MissingPartialPolicy::Error =>
          raise TemplateError("missing partial: \{name}")
        MissingPartialPolicy::Preserve => indent + "{{>" + name + "}}"
      }
  }
}

///|
fn apply_partial_indent(content : String, indent : String) -> String {
  if indent.length() == 0 {
    return content
  }
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
}

///|
fn array_contains(items : Array[String], value : String) -> Bool {
  for item in items {
    if item == value {
      return true
    }
  }
  false
}

///|
fn array_append(items : Array[String], value : String) -> Array[String] {
  let result : Array[String] = []
  for item in items {
    result.push(item)
  }
  result.push(value)
  result
}

///|
fn enforce_nesting_limit(
  options : RenderOptions,
  depth : Int,
) -> Unit raise TemplateError {
  if options.max_nesting_depth() > 0 && depth > options.max_nesting_depth() {
    raise TemplateError("maximum render nesting depth exceeded")
  }
}

///|
fn enforce_output_limit(
  options : RenderOptions,
  output : String,
) -> Unit raise TemplateError {
  if options.max_output_length() > 0 &&
    output.length() > options.max_output_length() {
    raise TemplateError("rendered output exceeds configured limit")
  }
}
