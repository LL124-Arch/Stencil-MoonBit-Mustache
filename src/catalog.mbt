/// A deterministic in-memory catalog for applications that serve more than one
/// template. The catalog owns source text, compiled templates, and revision
/// state so a service can validate a release before accepting render requests.

///|
pub(all) struct TemplateEntry {
  /// Stable application-facing template name.
  name : String
  /// Mustache source associated with the name.
  source : String
} derive(Debug, Eq)

///|
pub fn TemplateEntry::new(name : String, source : String) -> TemplateEntry {
  { name, source }
}

///|
pub fn TemplateEntry::name(self : TemplateEntry) -> String {
  self.name
}

///|
pub fn TemplateEntry::source(self : TemplateEntry) -> String {
  self.source
}

///|
/// A collection of named templates with an invalidation-aware compile cache.
///
/// Replacing a source increments the revision and drops only the affected
/// compiled item. This makes hot reload and startup validation predictable
/// without forcing callers to manage a second source-to-template map.
pub struct TemplateCatalog {
  sources : Map[String, String]
  compiled : Map[String, Template]
  mut revision_number : Int
} derive(Debug)

///|
pub fn TemplateCatalog::new() -> TemplateCatalog {
  { sources: Map([]), compiled: Map([]), revision_number: 0 }
}

///|
/// Build a catalog from a manifest of named sources.
pub fn TemplateCatalog::from_entries(
  entries : Array[TemplateEntry],
) -> TemplateCatalog raise TemplateError {
  let catalog = TemplateCatalog::new()
  for entry in entries {
    catalog.register(entry.name, entry.source)
  }
  catalog
}

///|
/// Return the current source revision. A consumer can persist this value in a
/// deployment report and detect whether a render cache is stale.
pub fn TemplateCatalog::revision(self : TemplateCatalog) -> Int {
  self.revision_number
}

///|
/// Return all names in deterministic insertion order.
pub fn TemplateCatalog::names(self : TemplateCatalog) -> Array[String] {
  let names : Array[String] = []
  self.sources.each((name, _) => names.push(name))
  names
}

///|
/// Return the number of registered sources.
pub fn TemplateCatalog::template_count(self : TemplateCatalog) -> Int {
  self.sources.length()
}

///|
/// Return whether a name has been registered.
pub fn TemplateCatalog::contains(self : TemplateCatalog, name : String) -> Bool {
  self.sources.get(name) is Some(_)
}

///|
/// Return the original source for a name.
pub fn TemplateCatalog::source(
  self : TemplateCatalog,
  name : String,
) -> String? {
  self.sources.get(name)
}

///|
/// Return whether the name currently has a valid compiled cache entry.
pub fn TemplateCatalog::is_compiled(
  self : TemplateCatalog,
  name : String,
) -> Bool {
  self.compiled.get(name) is Some(_)
}

///|
/// Return the number of cached compiled templates.
pub fn TemplateCatalog::compiled_count(self : TemplateCatalog) -> Int {
  self.compiled.length()
}

///|
/// Return the total UTF-16 source length owned by the catalog.
pub fn TemplateCatalog::source_length(self : TemplateCatalog) -> Int {
  let mut result = 0
  self.sources.each((_, source) => result += source.length())
  result
}

///|
/// Return the number of sources that contain no executable text.
pub fn TemplateCatalog::empty_source_count(self : TemplateCatalog) -> Int {
  let mut result = 0
  self.sources.each((_, source) => if source.length() == 0 { result += 1 })
  result
}

///|
/// Return all structural metrics in catalog name order.
pub fn TemplateCatalog::stats_all(
  self : TemplateCatalog,
) -> Array[(String, TemplateStats)] raise TemplateError {
  let result : Array[(String, TemplateStats)] = []
  for name in self.names() {
    result.push((name, self.stats(name)))
  }
  result
}

///|
/// Return the names of templates whose source contains a given literal token.
/// This small source index is useful for editor search and targeted rebuilds.
pub fn TemplateCatalog::names_containing(
  self : TemplateCatalog,
  token : String,
) -> Array[String] {
  let result : Array[String] = []
  for name in self.names() {
    match self.sources.get(name) {
      Some(source) =>
        if source.contains(token) {
          result.push(name)
        } else {
          ()
        }
      None => ()
    }
  }
  result
}

///|
/// Add or replace a named source.
pub fn TemplateCatalog::register(
  self : TemplateCatalog,
  name : String,
  source : String,
) -> Unit raise TemplateError {
  if name.length() == 0 {
    raise TemplateError("template name cannot be empty")
  }
  if trim_spaces(name).length() != name.length() {
    raise TemplateError(
      "template name cannot have surrounding whitespace: \{name}",
    )
  }
  self.sources.set(name, source)
  self.compiled.remove(name)
  self.revision_number += 1
}

///|
/// Register several entries as one application update. If an entry is invalid,
/// the update stops at that entry and the previous entries remain registered;
/// callers should use `from_entries` for all-or-nothing startup construction.
pub fn TemplateCatalog::register_many(
  self : TemplateCatalog,
  entries : Array[TemplateEntry],
) -> Unit raise TemplateError {
  for entry in entries {
    self.register(entry.name, entry.source)
  }
}

///|
/// Remove a template and its cached compilation. Returns false when absent.
pub fn TemplateCatalog::remove(self : TemplateCatalog, name : String) -> Bool {
  if self.sources.get(name) is Some(_) {
    self.sources.remove(name)
    self.compiled.remove(name)
    self.revision_number += 1
    true
  } else {
    false
  }
}

///|
/// Remove all templates and reset the revision to zero.
pub fn TemplateCatalog::clear(self : TemplateCatalog) -> Unit {
  for name in self.names() {
    self.sources.remove(name)
    self.compiled.remove(name)
  }
  self.revision_number = 0
}

///|
/// Compile one named source and store it in the cache.
pub fn TemplateCatalog::compile_named(
  self : TemplateCatalog,
  name : String,
) -> Template raise TemplateError {
  match self.sources.get(name) {
    Some(source) => {
      let template = compile(source)
      self.compiled.set(name, template)
      template
    }
    None => raise TemplateError("missing template: \{name}")
  }
}

///|
/// Compile every registered source and return a copy of the cache.
pub fn TemplateCatalog::compile_all(
  self : TemplateCatalog,
) -> Map[String, Template] raise TemplateError {
  let result : Map[String, Template] = Map([])
  for name in self.names() {
    let template = self.compile_named(name)
    result.set(name, template)
  }
  result
}

///|
/// Return a cached template, compiling it lazily when necessary.
pub fn TemplateCatalog::template(
  self : TemplateCatalog,
  name : String,
) -> Template raise TemplateError {
  match self.compiled.get(name) {
    Some(template) => template
    None => self.compile_named(name)
  }
}

///|
/// Compile every source while retaining all errors for release tooling.
pub fn TemplateCatalog::compile_report(
  self : TemplateCatalog,
) -> CatalogCompileReport {
  let errors : Array[CatalogCompileError] = []
  let compiled_before = self.compiled_count()
  for name in self.names() {
    ignore(self.compile_named(name)) catch {
      TemplateError(message) =>
        errors.push(CatalogCompileError::new(name, message))
    }
  }
  {
    template_count: self.template_count(),
    compiled_count: self.compiled_count(),
    compiled_before,
    error_count: errors.length(),
    errors,
    revision: self.revision(),
  }
}

///|
/// Return a compact deployment-oriented catalog summary.
pub fn TemplateCatalog::manifest_summary(self : TemplateCatalog) -> String {
  let templates = self.template_count()
  let compiled = self.compiled_count()
  let revision = self.revision()
  "templates=\{templates}, compiled=\{compiled}, revision=\{revision}"
}

///|
/// Return direct partial dependencies of a named template.
pub fn TemplateCatalog::dependencies(
  self : TemplateCatalog,
  name : String,
) -> Array[String] raise TemplateError {
  match self.sources.get(name) {
    Some(source) => partial_references(source)
    None => raise TemplateError("missing template: \{name}")
  }
}

///|
/// Return structural metrics for a named template.
pub fn TemplateCatalog::stats(
  self : TemplateCatalog,
  name : String,
) -> TemplateStats raise TemplateError {
  self.template(name).stats()
}

///|
/// Return every direct dependency edge as `(template, partial)` pairs.
pub fn TemplateCatalog::dependency_edges(
  self : TemplateCatalog,
) -> Array[(String, String)] {
  let edges : Array[(String, String)] = []
  for name in self.names() {
    match self.sources.get(name) {
      Some(source) =>
        for dependency in partial_references(source) {
          edges.push((name, dependency))
        }
      None => ()
    }
  }
  edges
}

///|
/// Return names that reference a given partial directly.
pub fn TemplateCatalog::dependents(
  self : TemplateCatalog,
  partial : String,
) -> Array[String] {
  let result : Array[String] = []
  for name in self.names() {
    let dependencies = self.dependencies(name) catch { _ => [] }
    if dependencies.contains(partial) {
      result.push(name)
    } else {
      ()
    }
  }
  result
}

///|
/// Validate all sources and return diagnostics grouped without raising.
pub fn TemplateCatalog::diagnostics(
  self : TemplateCatalog,
) -> Array[CatalogDiagnostic] {
  let result : Array[CatalogDiagnostic] = []
  for name in self.names() {
    match self.sources.get(name) {
      Some(source) =>
        for diagnostic in diagnose(source) {
          result.push(CatalogDiagnostic::from_template(name, diagnostic))
        }
      None => ()
    }
  }
  result
}
