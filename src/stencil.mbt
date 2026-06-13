/// Stencil 模板引擎 - 公开 API
///
/// 提供模板编译和渲染的核心接口。
/// 支持 Mustache 风格的模板语法，包括变量插值、条件渲染、列表迭代等。

///|
/// 一步完成模板渲染
/// 传入模板字符串和 Json 数据，返回渲染结果
pub fn render(template : String, data : Json) -> String raise TemplateError {
  let tpl = compile(template)
  tpl.render(data)
}

///|
/// 带局部模板的渲染
/// partials 参数提供可引用的子模板
pub fn render_with_partials(
  template : String,
  data : Json,
  partial_sources : Map[String, String],
) -> String raise TemplateError {
  let tpl = compile(template)
  // 编译所有 partial
  let compiled_partials : Map[String, Array[Node]] = {}
  partial_sources.each(fn(name, src) {
    // partial 编译失败时忽略（降级为空输出）
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
/// 编译模板字符串为 Template 对象
/// 编译一次可以用不同数据多次渲染
pub fn compile(source : String) -> Template raise TemplateError {
  let tokens = scan(source)
  let nodes = parse(tokens)
  { source, nodes }
}

///|
/// 用给定数据渲染已编译的模板
pub fn Template::render(self : Template, data : Json) -> String {
  let ctx = Context::new(data)
  let partials : Map[String, Array[Node]] = {}
  render_nodes(self.nodes, ctx, partials)
}

///|
/// 用给定数据和局部模板渲染
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
