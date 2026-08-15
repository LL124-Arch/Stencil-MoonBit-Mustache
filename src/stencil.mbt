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
  let compiled_partials : Map[String, Array[Node]] = Map([])
  partial_sources.each((name, src) => {
    try {
      let p = compile(src)
      compiled_partials.set(name, p.nodes)
    } catch {
      _ => ()
    }
  })
  let ctx = Context::new(data)
  render_nodes_checked(tpl.nodes, ctx, compiled_partials, 0)
}

///|
/// Render a template with explicit rendering policies.
pub fn render_with_options(
  template : String,
  data : Json,
  options : RenderOptions,
) -> String raise TemplateError {
  let tpl = compile(template)
  tpl.render_with_options(data, options)
}

///|
/// Render a template and named partials with explicit rendering policies.
pub fn render_with_options_and_partials(
  template : String,
  data : Json,
  partial_sources : Map[String, String],
  options : RenderOptions,
) -> String raise TemplateError {
  let tpl = compile(template)
  tpl.render_with_options_and_partials(data, partial_sources, options)
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
  let partials : Map[String, Array[Node]] = Map([])
  render_nodes(self.nodes, ctx, partials)
}

///|
/// Render a precompiled template with named partial sources.
pub fn Template::render_with(
  self : Template,
  data : Json,
  partial_sources : Map[String, String],
) -> String {
  self.render_with_options_and_partials(
    data,
    partial_sources,
    RenderOptions::default(),
  ) catch {
    _ => ""
  }
}

///|
/// Render a precompiled template under explicit rendering policies.
pub fn Template::render_with_options(
  self : Template,
  data : Json,
  options : RenderOptions,
) -> String raise TemplateError {
  let ctx = Context::new(data)
  let partials : Map[String, Array[Node]] = Map([])
  render_nodes_with_options(self.nodes, ctx, partials, options, 0, [])
}

///|
/// Render a precompiled template with named partials and explicit policies.
pub fn Template::render_with_options_and_partials(
  self : Template,
  data : Json,
  partial_sources : Map[String, String],
  options : RenderOptions,
) -> String raise TemplateError {
  let compiled_partials : Map[String, Array[Node]] = Map([])
  partial_sources.each((name, src) => {
    let p = compile(src)
    compiled_partials.set(name, p.nodes)
  })
  let ctx = Context::new(data)
  render_nodes_with_options(self.nodes, ctx, compiled_partials, options, 0, [])
}
