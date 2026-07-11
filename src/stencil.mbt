/// Public Stencil API.

///|
/// Compile and render a template in one step.
pub fn render(template : String, data : Json) -> String raise TemplateError {
  let tpl = compile(template)
  tpl.render(data)
}

///|
/// Render a template with named partial sources.
pub fn render_with_partials(
  template : String,
  data : Json,
  partial_sources : Map[String, String],
) -> String raise TemplateError {
  let tpl = compile(template)
  let compiled_partials : Map[String, Array[Node]] = {}
  partial_sources.each(fn(name, src) {
    try {
      let p = compile(src)
      compiled_partials.set(name, p.nodes)
    } catch {
      _ => ()
    }
  })
  let ctx = Context::new(data)
  render_nodes(tpl.nodes, ctx, compiled_partials)
}

///|
/// Compile a raw template string into a reusable template value.
pub fn compile(source : String) -> Template raise TemplateError {
  let tokens = scan(source)
  let nodes = parse(tokens)
  { source, nodes }
}

///|
/// Render a precompiled template with the provided data context.
pub fn Template::render(self : Template, data : Json) -> String {
  let ctx = Context::new(data)
  let partials : Map[String, Array[Node]] = {}
  render_nodes(self.nodes, ctx, partials)
}

///|
/// Render a precompiled template with named partial sources.
pub fn Template::render_with(
  self : Template,
  data : Json,
  partial_sources : Map[String, String],
) -> String {
  let compiled_partials : Map[String, Array[Node]] = {}
  partial_sources.each(fn(name, src) {
    try {
      let p = compile(src)
      compiled_partials.set(name, p.nodes)
    } catch {
      _ => ()
    }
  })
  let ctx = Context::new(data)
  render_nodes(self.nodes, ctx, compiled_partials)
}
