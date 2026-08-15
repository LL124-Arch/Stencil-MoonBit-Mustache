///|
test "partial store supports lifecycle and rendering" {
  let store = PartialStore::new()
  store.set("card", "<b>{{title}}</b>")
  assert_eq(store.contains("card"), true)
  let card = store.get("card")
  assert_eq(card is Some("<b>{{title}}</b>"), true)
  assert_eq(store.render("{{>card}}", { "title": "A" }), "<b>A</b>")
  store.remove("card")
  assert_eq(store.contains("card"), false)
}

///|
test "partial store exposes dependencies and metrics" {
  let store = PartialStore::from_map({
    "page": "{{>header}}body{{>footer}}",
    "header": "<h1>{{title}}</h1>",
    "footer": "<footer>ok</footer>",
  })
  let dependencies = store.dependencies("page")
  assert_eq(dependencies.length(), 2)
  assert_eq(dependencies[0], "header")
  assert_eq(dependencies[1], "footer")
  let stats = store.stats("header")
  assert_eq(stats.variable_count, 1)
  assert_eq(stats.node_count, 4)
  assert_eq(store.names().length(), 3)
}

///|
test "partial store validates all sources" {
  let store = PartialStore::from_map({
    "good": "Hello {{name}}",
    "bad": "{{#open}}",
  })
  let diagnostics = store.validate()
  assert_eq(diagnostics.length(), 1)
}

///|
test "partial store compiles all sources" {
  let store = PartialStore::from_map({ "a": "A", "b": "{{>a}}" })
  let compiled = store.compile_all()
  assert_eq(compiled.get("a") is Some(_), true)
  assert_eq(compiled.get("b") is Some(_), true)
}
