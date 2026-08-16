# TemplateCatalog application guide

`TemplateCatalog` is the recommended boundary when an application owns more
than one template. It provides a source manifest, a lazy compilation cache, a
revision number, dependency analysis, and failure-preserving batch rendering.
It does not read files or access a network; callers decide how sources enter the
catalog, which keeps the MoonBit library deterministic and portable.

## Startup validation

Register sources with `TemplateEntry::new` and construct a catalog with
`TemplateCatalog::from_entries`. Before serving requests, inspect:

```moonbit
let health = catalog.health_report()
if !health.is_healthy() {
  println(health.summary())
}
```

The health report combines syntax/compile diagnostics with missing partials and
partial cycles. `compile_all` can be used as a fail-fast gate when deployment
must reject the first invalid template instead of collecting all failures.

## Page and email batches

`CatalogRenderJob` represents one named template and JSON context. Use
`render_jobs` for mixed page/email/configuration queues, or
`render_many_named` for one template applied to many records:

```moonbit
let jobs = [
  @stencil.CatalogRenderJob::new("email", { "name": "Ada" }),
  @stencil.CatalogRenderJob::new("email", { "name": "Grace" }),
]
let result = catalog.render_jobs(
  jobs,
  partials,
  @stencil.RenderOptions::default().with_max_output_length(100_000),
)
```

Successful outputs remain in job order. Failures expose the original template
name, job index, and error message, so a queue consumer can retry or dead-letter
only the failed record. `machine_summary`, `checksum`, and output lengths make
the report suitable for CI and deterministic fixture comparison.

## Caching and hot reload

`compile_named` populates the cache. Registering a replacement source removes
only that name's compiled entry and increments `revision()`. This allows a
development server or configuration watcher to invalidate one template without
recompiling unrelated pages. `manifest_summary` exposes template count, cache
count, and revision for logs.

## Partitioning large queues

`render_job_range` lets a caller split a queue into half-open ranges. Independent
reports can be combined with `CatalogRenderReport::merge`; output order and
job-index offsets remain explicit. `matches_contents` provides a small golden
fixture assertion for release checks.

## Deliberate boundaries

The catalog remains an in-memory orchestration layer. Filesystem loading,
network fetches, template-language extensions, and application retry policies
belong to the host application. The renderer's safety limits and Mustache
compatibility boundaries continue to apply to every catalog render.
