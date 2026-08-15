/// Template AST analysis for tooling, caching, and acceptance evidence.

///|
fn merge_stats(left : TemplateStats, right : TemplateStats) -> TemplateStats {
  {
    node_count: left.node_count + right.node_count,
    text_node_count: left.text_node_count + right.text_node_count,
    variable_count: left.variable_count + right.variable_count,
    raw_variable_count: left.raw_variable_count + right.raw_variable_count,
    section_count: left.section_count + right.section_count,
    inverted_section_count: left.inverted_section_count +
    right.inverted_section_count,
    partial_count: left.partial_count + right.partial_count,
    max_depth: if left.max_depth > right.max_depth {
      left.max_depth
    } else {
      right.max_depth
    },
    has_custom_delimiters: left.has_custom_delimiters ||
    right.has_custom_delimiters,
  }
}

///|
fn node_stats(node : Node, depth : Int) -> TemplateStats {
  let base = empty_stats()
  match node {
    TextNode(_) =>
      { ..base, node_count: 1, text_node_count: 1, max_depth: depth }
    VarNode(_, escaped) =>
      if escaped {
        { ..base, node_count: 1, variable_count: 1, max_depth: depth }
      } else {
        { ..base, node_count: 1, raw_variable_count: 1, max_depth: depth }
      }
    SectionNode(_, children, inverted) => {
      let child_stats = nodes_stats(children, depth + 1)
      let section_stats = if inverted {
        { ..base, node_count: 1, inverted_section_count: 1, max_depth: depth }
      } else {
        { ..base, node_count: 1, section_count: 1, max_depth: depth }
      }
      merge_stats(section_stats, child_stats)
    }
    PartialNode(_, _) =>
      { ..base, node_count: 1, partial_count: 1, max_depth: depth }
  }
}

///|
fn nodes_stats(nodes : Array[Node], depth : Int) -> TemplateStats {
  let mut result = empty_stats()
  for node in nodes {
    result = merge_stats(result, node_stats(node, depth))
  }
  result
}

///|
/// Return structural metrics for a compiled template.
pub fn Template::stats(self : Template) -> TemplateStats {
  let result = nodes_stats(self.nodes, 0)
  let root_count = if self.nodes.length() == 0 { 0 } else { 1 }
  {
    ..result,
    node_count: result.node_count + root_count,
    has_custom_delimiters: self.source.contains("{{="),
  }
}

///|
/// Return a compact human-readable summary suitable for CLI output.
pub fn TemplateStats::summary(self : TemplateStats) -> String {
  let _ = self
  "nodes=\{self.node_count}, text=\{self.text_node_count}, vars=\{self.variable_count}, " +
  "raw=\{self.raw_variable_count}, sections=\{self.section_count}, " +
  "inverted=\{self.inverted_section_count}, partials=\{self.partial_count}, " +
  "depth=\{self.max_depth}, custom_delimiters=\{self.has_custom_delimiters}"
}
