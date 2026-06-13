///|
/// 语法分析器：将 Token 序列构建为 Node 语法树
/// 主要处理 Section 的嵌套匹配
pub fn parse(tokens : Array[Token]) -> Array[Node] raise TemplateError {
  let result = parse_inner(tokens, 0, "")
  result.0
}

///|
/// 递归解析，返回 (节点列表, 消耗的 token 数量)
/// until 参数指定当前层级的终止 section 名称，空字符串表示顶层
fn parse_inner(
  tokens : Array[Token],
  start : Int,
  until : String,
) -> (Array[Node], Int) raise TemplateError {
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
      Comment(_) =>
        // 注释不生成节点
        i = i + 1
      Partial(name) => {
        nodes.push(PartialNode(name, ""))
        i = i + 1
      }
      SectionOpen(name) => {
        // 递归解析直到匹配的 SectionClose
        let inner = parse_inner(tokens, i + 1, name)
        let children = inner.0
        let consumed = inner.1
        nodes.push(SectionNode(name, children, false))
        i = i + 1 + consumed
      }
      InvertedOpen(name) => {
        let inner = parse_inner(tokens, i + 1, name)
        let children = inner.0
        let consumed = inner.1
        nodes.push(SectionNode(name, children, true))
        i = i + 1 + consumed
      }
      SectionClose(name) => {
        if until.length() == 0 {
          raise TemplateError("意外的关闭标签: \{name}")
        }
        if name != until {
          raise TemplateError(
            "标签不匹配: 期望 \{until}，实际 \{name}",
          )
        }
        // +1 是为了跳过这个 close 标签本身
        return (nodes, i - start + 1)
      }
    }
  }
  // 如果还在等待关闭标签但已经到末尾了
  if until.length() > 0 {
    raise TemplateError("未关闭的区块: \{until}")
  }
  (nodes, i - start)
}
