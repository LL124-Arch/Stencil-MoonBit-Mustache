///| TemplateCatalog behavior is specified before its implementation.

///|
test "catalog registers and renders named templates" {
  let catalog = TemplateCatalog::new()
  catalog.register("welcome", "Hello {{name}}!")
  assert_true(catalog.contains("welcome"))
  assert_eq(
    catalog.render_named(
      "welcome",
      { "name": "Ada" },
      {},
      RenderOptions::default(),
    ),
    "Hello Ada!",
  )
}

///|
test "catalog compiles a partial-aware template set" {
  let catalog = TemplateCatalog::from_entries([
    TemplateEntry::new("page", "{{>header}}\n{{#items}}{{name}}\n{{/items}}"),
    TemplateEntry::new("header", "# {{title}}"),
  ])
  let report = catalog.compile_report()
  assert_eq(report.template_count, 2)
  assert_eq(report.error_count, 0)
  assert_true(catalog.dependencies("page") == ["header"])
}

///|
test "catalog batch report preserves failures and checksums" {
  let catalog = TemplateCatalog::from_entries([
    TemplateEntry::new("card", "<h1>{{title}}</h1>"),
  ])
  let jobs = [
    CatalogRenderJob::new("card", { "title": "One" }),
    CatalogRenderJob::new("card", { "title": "Two" }),
    CatalogRenderJob::new("missing", {}),
  ]
  let report = catalog.render_jobs(jobs, {}, RenderOptions::default())
  assert_eq(report.total_jobs, 3)
  assert_eq(report.success_count, 2)
  assert_eq(report.failure_count, 1)
  assert_eq(report.outputs.length(), 2)
  assert_true(report.checksum > 0)
}

///|
test "catalog revision invalidates compiled cache on replacement" {
  let catalog = TemplateCatalog::new()
  assert_eq(catalog.revision(), 0)
  catalog.register("value", "{{value}}")
  assert_eq(catalog.revision(), 1)
  ignore(catalog.compile_all())
  assert_true(catalog.is_compiled("value"))
  catalog.register("value", "v={{value}}")
  assert_eq(catalog.revision(), 2)
  assert_false(catalog.is_compiled("value"))
  assert_eq(
    catalog.render_named(
      "value",
      { "value": "x" },
      {},
      RenderOptions::default(),
    ),
    "v=x",
  )
}

///|
test "catalog manifest summary is deterministic" {
  let catalog = TemplateCatalog::from_entries([
    TemplateEntry::new("a", "A"),
    TemplateEntry::new("b", "{{x}}"),
  ])
  assert_eq(catalog.manifest_summary(), "templates=2, compiled=0, revision=2")
  ignore(catalog.compile_all())
  assert_eq(catalog.manifest_summary(), "templates=2, compiled=2, revision=2")
}

///|
test "catalog health report catches missing partials and syntax errors" {
  let catalog = TemplateCatalog::from_entries([
    TemplateEntry::new("broken", "{{#items}}"),
    TemplateEntry::new("page", "{{>missing}}"),
  ])
  let health = catalog.health_report()
  assert_false(health.is_healthy())
  assert_eq(health.compile().error_count, 1)
  assert_eq(health.dependencies().missing_count(), 1)
  assert_true(health.diagnostics().length() > 0)
}

///|
test "catalog dependency report catches partial cycles" {
  let catalog = TemplateCatalog::from_entries([
    TemplateEntry::new("a", "{{>b}}"),
    TemplateEntry::new("b", "{{>c}}"),
    TemplateEntry::new("c", "{{>a}}"),
  ])
  let report = catalog.dependency_report()
  assert_eq(report.edge_count(), 3)
  assert_eq(report.missing_count(), 0)
  assert_eq(report.cycle_count(), 1)
  assert_false(report.is_valid())
}

///|
test "catalog render report exposes output metrics" {
  let catalog = TemplateCatalog::from_entries([
    TemplateEntry::new("one", "{{x}}"),
    TemplateEntry::new("two", "{{x}}{{x}}"),
  ])
  let report = catalog.render_all({ "x": "ok" }, RenderOptions::default())
  assert_true(report.is_complete())
  assert_eq(report.success_count(), 2)
  assert_eq(report.failure_count(), 0)
  assert_true(report.contents() == ["ok", "okok"])
  assert_eq(report.min_output_length(), 2)
  assert_eq(report.max_output_length(), 4)
  assert_true(report.all_outputs_nonempty())
}

///|
test "catalog rejects unstable names and supports removal" {
  let catalog = TemplateCatalog::new()
  try {
    catalog.register(" page", "x")
    assert_true(false)
  } catch {
    TemplateError(message) => assert_true(message.contains("whitespace"))
    _ => assert_true(false)
  }
  catalog.register("page", "x")
  assert_true(catalog.remove("page"))
  assert_false(catalog.remove("page"))
  catalog.clear()
  assert_eq(catalog.template_count(), 0)
  assert_eq(catalog.revision(), 0)
}

///|
test "catalog indexes source size and structural metrics" {
  let catalog = TemplateCatalog::from_entries([
    TemplateEntry::new("page", "{{>header}} {{name}}"),
    TemplateEntry::new("header", "# title"),
    TemplateEntry::new("empty", ""),
  ])
  assert_eq(catalog.source_length(), 27)
  assert_eq(catalog.empty_source_count(), 1)
  assert_true(catalog.names_containing("{{>") == ["page"])
  assert_eq(catalog.stats_all().length(), 3)
}

///|
test "catalog range reports merge without losing order" {
  let catalog = TemplateCatalog::from_entries([
    TemplateEntry::new("item", "{{value}}"),
  ])
  let jobs = [
    CatalogRenderJob::new("item", { "value": "a" }),
    CatalogRenderJob::new("item", { "value": "b" }),
    CatalogRenderJob::new("item", { "value": "c" }),
  ]
  let left = catalog.render_job_range(jobs, 0, 2, {}, RenderOptions::default())
  let right = catalog.render_job_range(jobs, 2, 3, {}, RenderOptions::default())
  let merged = left.merge(right)
  assert_true(merged.matches_contents(["a", "b", "c"]))
  assert_eq(merged.average_output_length(), 1)
  assert_eq(merged.output_for_job(2).unwrap().content(), "c")
  assert_eq(
    merged.machine_summary(),
    "jobs=3,success=3,failures=0,average_length=1,checksum=392,complete=true",
  )
}
