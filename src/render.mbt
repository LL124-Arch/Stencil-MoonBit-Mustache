/// 渲染引擎：遍历 AST 节点，结合数据上下文输出字符串

///|
/// 根据节点列表和上下文生成最终文本
pub fn render_nodes(
  nodes : Array[Node],
  ctx : Context,
  partials : Map[String, Array[Node]],
) -> String {
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
          render_section(name, children, inverted, ctx, partials),
        )
      PartialNode(name, indent) =>
        buf.write_string(render_partial(name, indent, ctx, partials))
    }
    i = i + 1
  }
  buf.to_string()
}

///|
/// 渲染区块节点
fn render_section(
  name : String,
  children : Array[Node],
  inverted : Bool,
  ctx : Context,
  partials : Map[String, Array[Node]],
) -> String {
  let val = ctx.find(name)
  if inverted {
    // 反转区块：值为假时渲染
    if is_truthy(val) {
      return ""
    }
    return render_nodes(children, ctx, partials)
  }
  // 正向区块
  match val {
    Null => ""
    False => ""
    True => render_nodes(children, ctx, partials)
    Array(items) => {
      // 数组迭代
      if items.length() == 0 {
        return ""
      }
      let buf = StringBuilder::new()
      let mut idx = 0
      while idx < items.length() {
        ctx.push(items[idx])
        buf.write_string(render_nodes(children, ctx, partials))
        ctx.pop()
        idx = idx + 1
      }
      buf.to_string()
    }
    Object(_) => {
      // 对象作为子上下文
      ctx.push(val)
      let result = render_nodes(children, ctx, partials)
      ctx.pop()
      result
    }
    String(s) =>
      if s.length() == 0 {
        ""
      } else {
        render_nodes(children, ctx, partials)
      }
    Number(_, ..) => render_nodes(children, ctx, partials)
  }
}

///|
/// 渲染局部模板
fn render_partial(
  name : String,
  indent : String,
  ctx : Context,
  partials : Map[String, Array[Node]],
) -> String {
  match partials.get(name) {
    Some(nodes) => {
      let content = render_nodes(nodes, ctx, partials)
      if indent.length() > 0 {
        // 给每一行添加缩进
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
