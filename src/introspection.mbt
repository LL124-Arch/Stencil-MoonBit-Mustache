/// Reusable inspection and batch-rendering helpers.

///|
/// Return the exact source used to compile a template.
pub fn Template::source_text(self : Template) -> String {
  self.source
}

///|
/// Return the number of top-level AST nodes. This is intentionally separate
/// from TemplateStats::node_count, which includes the synthetic root node.
pub fn Template::top_level_node_count(self : Template) -> Int {
  self.nodes.length()
}

///|
/// Render many JSON documents with one compiled template.
pub fn Template::render_many(
  self : Template,
  documents : Array[Json],
) -> Array[String] {
  let result : Array[String] = []
  for document in documents {
    result.push(self.render(document))
  }
  result
}

///|
/// Render many JSON documents with explicit policies.
pub fn Template::render_many_with_options(
  self : Template,
  documents : Array[Json],
  options : RenderOptions,
) -> Array[String] raise TemplateError {
  let result : Array[String] = []
  for document in documents {
    result.push(self.render_with_options(document, options))
  }
  result
}

///|
/// Return a stable human-readable diagnostic summary for command-line tools.
pub fn TemplateDiagnostic::summary(self : TemplateDiagnostic) -> String {
  let severity = match self.severity {
    DiagnosticSeverity::Error => "error"
    DiagnosticSeverity::Warning => "warning"
    DiagnosticSeverity::Info => "info"
  }
  "\{severity} at \{self.line}:\{self.column}: \{self.message}"
}

///|
/// Classify a template by the number of constructs it contains.
pub fn TemplateStats::complexity_score(self : TemplateStats) -> Int {
  self.node_count +
  self.section_count * 2 +
  self.inverted_section_count * 2 +
  self.partial_count * 3
}

///|
/// Whether the template has no executable nodes.
pub fn TemplateStats::is_empty(self : TemplateStats) -> Bool {
  self.node_count == 0
}

///|
/// Analyze and return metrics without requiring callers to hold a Template.
pub fn analyze(source : String) -> TemplateStats raise TemplateError {
  compile(source).stats()
}
