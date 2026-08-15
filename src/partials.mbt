/// A small in-memory partial registry for applications and build tooling.
///
/// PartialStore keeps source ownership in one place, validates every partial
/// on demand, exposes dependency edges for diagnostics, and delegates actual
/// rendering to the same bounded engine as the top-level API.

///|
pub(all) struct PartialStore {
  sources : Map[String, String]
} derive(Debug)

///|
/// Create an empty registry.
pub fn PartialStore::new() -> PartialStore {
  { sources: Map([]) }
}

///|
/// Create a registry from an existing source map.
pub fn PartialStore::from_map(sources : Map[String, String]) -> PartialStore {
  { sources, }
}

///|
/// Add or replace one partial source.
pub fn PartialStore::set(
  self : PartialStore,
  name : String,
  source : String,
) -> Unit {
  self.sources.set(name, source)
}

///|
/// Remove a partial source. Removing a missing name is harmless.
pub fn PartialStore::remove(self : PartialStore, name : String) -> Unit {
  self.sources.remove(name)
}

///|
/// Return whether a named partial is registered.
pub fn PartialStore::contains(self : PartialStore, name : String) -> Bool {
  match self.sources.get(name) {
    Some(_) => true
    None => false
  }
}

///|
/// Read the original source of a partial.
pub fn PartialStore::get(self : PartialStore, name : String) -> String? {
  self.sources.get(name)
}

///|
/// Return registered names in map iteration order.
pub fn PartialStore::names(self : PartialStore) -> Array[String] {
  let result : Array[String] = []
  self.sources.each((name, _) => result.push(name))
  result
}

///|
/// Compile one partial and return structural metrics.
pub fn PartialStore::stats(
  self : PartialStore,
  name : String,
) -> TemplateStats raise TemplateError {
  match self.sources.get(name) {
    Some(source) => compile(source).stats()
    None => raise TemplateError("missing partial: \{name}")
  }
}

///|
/// Validate all registered partials before serving requests.
pub fn PartialStore::validate(self : PartialStore) -> Array[TemplateDiagnostic] {
  let result : Array[TemplateDiagnostic] = []
  self.sources.each((_, source) => {
    let diagnostics = diagnose(source)
    for item in diagnostics {
      result.push(item)
    }
  })
  result
}

///|
/// Render a template using this registry and legacy-compatible defaults.
pub fn PartialStore::render(
  self : PartialStore,
  template : String,
  data : Json,
) -> String raise TemplateError {
  self.render_with_options(template, data, RenderOptions::default())
}

///|
/// Render a template using this registry and explicit safety policies.
pub fn PartialStore::render_with_options(
  self : PartialStore,
  template : String,
  data : Json,
  options : RenderOptions,
) -> String raise TemplateError {
  render_with_options_and_partials(template, data, self.sources, options)
}

///|
/// Return direct partial references found in a registered source.
pub fn PartialStore::dependencies(
  self : PartialStore,
  name : String,
) -> Array[String] raise TemplateError {
  match self.sources.get(name) {
    Some(source) => partial_references(source)
    None => raise TemplateError("missing partial: \{name}")
  }
}

///|
/// Compile every partial. This is useful as a startup validation gate.
pub fn PartialStore::compile_all(
  self : PartialStore,
) -> Map[String, Template] raise TemplateError {
  let result : Map[String, Template] = Map([])
  self.sources.each((name, source) => {
    let template = compile(source)
    result.set(name, template)
  })
  result
}

///|
fn partial_references(source : String) -> Array[String] {
  let result : Array[String] = []
  let mut cursor = 0
  while cursor < source.length() {
    let start = find_str(source, "{{>", cursor)
    if start < 0 {
      break
    }
    let end = find_str(source, "}}", start + 3)
    if end < 0 {
      break
    }
    let name = trim_spaces(substring(source, start + 3, end))
    if name.length() > 0 && !result.contains(name) {
      result.push(name)
    }
    cursor = end + 2
  }
  result
}
