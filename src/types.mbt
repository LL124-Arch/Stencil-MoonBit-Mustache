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
impl Show for Token with fn output(self, logger) {
  match self {
    Text(s) => logger.write_string("Text(\{s})")
    Variable(s) => logger.write_string("Variable(\{s})")
    RawVariable(s) => logger.write_string("RawVariable(\{s})")
    SectionOpen(s) => logger.write_string("SectionOpen(\{s})")
    SectionClose(s) => logger.write_string("SectionClose(\{s})")
    InvertedOpen(s) => logger.write_string("InvertedOpen(\{s})")
    Partial(s) => logger.write_string("Partial(\{s})")
    Comment(s) => logger.write_string("Comment(\{s})")
  }
}

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
impl Show for Node with fn output(self, logger) {
  match self {
    TextNode(s) => logger.write_string("TextNode(\{s})")
    VarNode(s, b) => logger.write_string("VarNode(\{s}, \{b})")
    SectionNode(s, children, b) => {
      logger.write_string("SectionNode(\{s}, ")
      Show::output(children, logger)
      logger.write_string(", \{b})")
    }
    PartialNode(s1, s2) => logger.write_string("PartialNode(\{s1}, \{s2})")
  }
}

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
