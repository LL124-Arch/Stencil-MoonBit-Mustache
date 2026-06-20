///|
/// 词法分析阶段产出的标记类型
pub(all) enum Token {
  /// 纯文本内容
  Text(String)
  /// 普通变量 {{name}}
  Variable(String)
  /// 非转义变量 {{{name}}} 或 {{&name}}
  RawVariable(String)
  /// 区块开始 {{#section}}
  SectionOpen(String)
  /// 区块结束 {{/section}}
  SectionClose(String)
  /// 反转区块 {{^section}}
  InvertedOpen(String)
  /// 局部模板 {{>partial}}
  Partial(String)
  /// 注释 {{!comment}}
  Comment(String)
} derive(Debug, Eq)



///|
/// 语法树节点，由 parser 根据 token 序列构建
pub(all) enum Node {
  /// 纯文本
  TextNode(String)
  /// 变量输出 (变量名, 是否HTML转义)
  VarNode(String, Bool)
  /// 区块节点 (名称, 子节点, 是否反转)
  SectionNode(String, Array[Node], Bool)
  /// 局部模板 (名称, 缩进前缀)
  PartialNode(String, String)
} derive(Debug, Eq)



///|
/// 编译后的模板对象，可重复渲染
pub struct Template {
  /// 原始模板文本
  source : String
  /// 解析后的节点树
  nodes : Array[Node]
} derive(Debug)

///|
/// 模板处理过程中的错误
pub(all) suberror TemplateError {
  TemplateError(String)
} derive(Debug)

///|
impl Show for Token with output(self, logger) {
  Show::output(self.to_string(), logger)
}

///|
impl Show for Node with output(self, logger) {
  Show::output(self.to_string(), logger)
}
