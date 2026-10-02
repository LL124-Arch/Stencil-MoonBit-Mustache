/// Explicit method forwarding for derived traits on current MoonBit toolchains.

///|
pub extend BenchmarkResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend BenchmarkWorkload with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CatalogCompileError with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CatalogCompileError with Eq::{not_equal, equal}

///|
pub extend CatalogCompileReport with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CatalogDependencyReport with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CatalogDiagnostic with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CatalogDiagnostic with Eq::{not_equal, equal}

///|
pub extend CatalogHealthReport with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CatalogRenderFailure with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CatalogRenderJob with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CatalogRenderOutput with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CatalogRenderReport with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CompatibilityCase with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CompatibilityResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend DiagnosticSeverity with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend DiagnosticSeverity with Eq::{not_equal, equal}

///|
pub extend MissingPartialPolicy with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend MissingPartialPolicy with Eq::{not_equal, equal}

///|
pub extend Node with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Node with Eq::{not_equal, equal}

///|
pub extend PartialStore with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RenderOptions with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RenderOptions with Eq::{not_equal, equal}

///|
pub extend Template with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TemplateCatalog with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TemplateDiagnostic with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TemplateDiagnostic with Eq::{not_equal, equal}

///|
pub extend TemplateEntry with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TemplateEntry with Eq::{not_equal, equal}

///|
pub extend TemplateError with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TemplatePosition with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TemplatePosition with Eq::{not_equal, equal}

///|
pub extend TemplateStats with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TemplateStats with Eq::{not_equal, equal}

///|
pub extend Token with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Token with Eq::{not_equal, equal}
