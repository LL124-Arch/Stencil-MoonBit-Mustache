/// Release-time analysis for a TemplateCatalog. These values are deliberately
/// plain data so CI, editors, and deployment tooling can serialize or inspect
/// them without depending on the renderer's internal AST.

///|
/// A compile error associated with one catalog name.
pub(all) struct CatalogCompileError {
  template_name : String
  message : String
} derive(Debug, Eq)

///|
pub fn CatalogCompileError::new(
  template_name : String,
  message : String,
) -> CatalogCompileError {
  { template_name, message }
}

///|
pub fn CatalogCompileError::template_name(self : CatalogCompileError) -> String {
  self.template_name
}

///|
pub fn CatalogCompileError::message(self : CatalogCompileError) -> String {
  self.message
}

///|
/// Report returned by compile_report.
pub(all) struct CatalogCompileReport {
  template_count : Int
  compiled_count : Int
  compiled_before : Int
  error_count : Int
  errors : Array[CatalogCompileError]
  revision : Int
} derive(Debug)

///|
pub fn CatalogCompileReport::template_count(self : CatalogCompileReport) -> Int {
  self.template_count
}

///|
pub fn CatalogCompileReport::compiled_count(self : CatalogCompileReport) -> Int {
  self.compiled_count
}

///|
pub fn CatalogCompileReport::compiled_before(
  self : CatalogCompileReport,
) -> Int {
  self.compiled_before
}

///|
pub fn CatalogCompileReport::error_count(self : CatalogCompileReport) -> Int {
  self.error_count
}

///|
pub fn CatalogCompileReport::errors(
  self : CatalogCompileReport,
) -> Array[CatalogCompileError] {
  self.errors
}

///|
pub fn CatalogCompileReport::revision(self : CatalogCompileReport) -> Int {
  self.revision
}

///|
pub fn CatalogCompileReport::is_valid(self : CatalogCompileReport) -> Bool {
  self.error_count == 0 && self.template_count == self.compiled_count
}

///|
pub fn CatalogCompileReport::summary(self : CatalogCompileReport) -> String {
  let templates = self.template_count
  let compiled = self.compiled_count
  let errors = self.error_count
  let revision = self.revision
  "templates=\{templates}, compiled=\{compiled}, errors=\{errors}, revision=\{revision}"
}

///|
/// A diagnostic annotated with the catalog template that produced it.
pub(all) struct CatalogDiagnostic {
  template_name : String
  severity : DiagnosticSeverity
  message : String
  index : Int
  line : Int
  column : Int
} derive(Debug, Eq)

///|
pub fn CatalogDiagnostic::from_template(
  template_name : String,
  diagnostic : TemplateDiagnostic,
) -> CatalogDiagnostic {
  {
    template_name,
    severity: diagnostic.severity,
    message: diagnostic.message,
    index: diagnostic.index,
    line: diagnostic.line,
    column: diagnostic.column,
  }
}

///|
pub fn CatalogDiagnostic::template_name(self : CatalogDiagnostic) -> String {
  self.template_name
}

///|
pub fn CatalogDiagnostic::severity(
  self : CatalogDiagnostic,
) -> DiagnosticSeverity {
  self.severity
}

///|
pub fn CatalogDiagnostic::message(self : CatalogDiagnostic) -> String {
  self.message
}

///|
pub fn CatalogDiagnostic::line(self : CatalogDiagnostic) -> Int {
  self.line
}

///|
pub fn CatalogDiagnostic::column(self : CatalogDiagnostic) -> Int {
  self.column
}

///|
pub fn CatalogDiagnostic::summary(self : CatalogDiagnostic) -> String {
  let severity = match self.severity {
    DiagnosticSeverity::Error => "error"
    DiagnosticSeverity::Warning => "warning"
    DiagnosticSeverity::Info => "info"
  }
  let template_name = self.template_name
  let line = self.line
  let column = self.column
  let message = self.message
  "\{template_name}: \{severity} at \{line}:\{column}: \{message}"
}

///|
/// Missing and cyclic partial references found in the catalog.
pub(all) struct CatalogDependencyReport {
  missing : Array[(String, String)]
  cycles : Array[String]
  edge_count : Int
} derive(Debug)

///|
pub fn CatalogDependencyReport::missing(
  self : CatalogDependencyReport,
) -> Array[(String, String)] {
  self.missing
}

///|
pub fn CatalogDependencyReport::cycles(
  self : CatalogDependencyReport,
) -> Array[String] {
  self.cycles
}

///|
pub fn CatalogDependencyReport::edge_count(
  self : CatalogDependencyReport,
) -> Int {
  self.edge_count
}

///|
pub fn CatalogDependencyReport::missing_count(
  self : CatalogDependencyReport,
) -> Int {
  self.missing.length()
}

///|
pub fn CatalogDependencyReport::cycle_count(
  self : CatalogDependencyReport,
) -> Int {
  self.cycles.length()
}

///|
pub fn CatalogDependencyReport::is_valid(
  self : CatalogDependencyReport,
) -> Bool {
  self.missing.length() == 0 && self.cycles.length() == 0
}

///|
pub fn CatalogDependencyReport::summary(
  self : CatalogDependencyReport,
) -> String {
  let edges = self.edge_count
  let missing = self.missing.length()
  let cycles = self.cycles.length()
  "edges=\{edges}, missing=\{missing}, cycles=\{cycles}"
}

///|
/// Analyze missing direct partials and cycles before a catalog is published.
pub fn TemplateCatalog::dependency_report(
  self : TemplateCatalog,
) -> CatalogDependencyReport {
  let missing : Array[(String, String)] = []
  let cycles : Array[String] = []
  let edges = self.dependency_edges()
  for edge in edges {
    let (_, dependency) = edge
    if !self.contains(dependency) && !missing.contains(edge) {
      missing.push(edge)
    }
  }
  let visited : Map[String, Bool] = Map([])
  for name in self.names() {
    let path : Array[String] = []
    find_catalog_cycles(self, name, path, visited, cycles)
  }
  { missing, cycles, edge_count: edges.length() }
}

///|
/// Depth-first cycle detection over direct partial references.
fn find_catalog_cycles(
  catalog : TemplateCatalog,
  name : String,
  path : Array[String],
  visited : Map[String, Bool],
  cycles : Array[String],
) -> Unit {
  if path.contains(name) {
    let cycle = join_names(path_suffix(path, name), name)
    if !cycles.contains(cycle) {
      cycles.push(cycle)
    }
    return
  }
  if visited.get(name) is Some(true) {
    return
  }
  visited.set(name, true)
  let next_path = path.copy()
  next_path.push(name)
  let dependencies = catalog.dependencies(name) catch { _ => [] }
  for dependency in dependencies {
    if catalog.contains(dependency) {
      find_catalog_cycles(catalog, dependency, next_path, visited, cycles)
    }
  }
}

///|
/// Return the suffix beginning at the first occurrence of a name.
fn path_suffix(path : Array[String], name : String) -> Array[String] {
  let result : Array[String] = []
  let mut copying = false
  for item in path {
    if item == name {
      copying = true
    }
    if copying {
      result.push(item)
    }
  }
  result
}

///|
/// Join a cycle path without pulling a string formatting dependency into the
/// public API. The final name is repeated to make the loop obvious in logs.
fn join_names(names : Array[String], final_name : String) -> String {
  let builder = StringBuilder::new()
  let mut first = true
  for name in names {
    if !first {
      builder.write_string(" -> ")
    }
    builder.write_string(name)
    first = false
  }
  if !first {
    builder.write_string(" -> ")
  }
  builder.write_string(final_name)
  builder.to_string()
}

///|
/// Return a report that combines source diagnostics, compilation errors, and
/// dependency hazards for release dashboards.
pub(all) struct CatalogHealthReport {
  compile : CatalogCompileReport
  diagnostics : Array[CatalogDiagnostic]
  dependencies : CatalogDependencyReport
} derive(Debug)

///|
pub fn CatalogHealthReport::compile(
  self : CatalogHealthReport,
) -> CatalogCompileReport {
  self.compile
}

///|
pub fn CatalogHealthReport::diagnostics(
  self : CatalogHealthReport,
) -> Array[CatalogDiagnostic] {
  self.diagnostics
}

///|
pub fn CatalogHealthReport::dependencies(
  self : CatalogHealthReport,
) -> CatalogDependencyReport {
  self.dependencies
}

///|
pub fn CatalogHealthReport::is_healthy(self : CatalogHealthReport) -> Bool {
  self.compile.is_valid() &&
  self.diagnostics.length() == 0 &&
  self.dependencies.is_valid()
}

///|
pub fn CatalogHealthReport::summary(self : CatalogHealthReport) -> String {
  let compile = self.compile.summary()
  let diagnostics = self.diagnostics.length()
  let dependencies = self.dependencies.summary()
  "compile(\{compile}), diagnostics=\{diagnostics}, dependencies(\{dependencies})"
}

///|
/// Run every static catalog health check in one call.
pub fn TemplateCatalog::health_report(
  self : TemplateCatalog,
) -> CatalogHealthReport {
  {
    compile: self.compile_report(),
    diagnostics: self.diagnostics(),
    dependencies: self.dependency_report(),
  }
}
