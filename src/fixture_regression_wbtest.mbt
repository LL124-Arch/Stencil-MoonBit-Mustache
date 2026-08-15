/// Representative application fixtures used for final acceptance.

///|
test "fixture html card" {
  let template = "<article><h2>{{title}}</h2><p>{{body}}</p></article>"
  let data : Json = { "title": "Release", "body": "Ready" }
  assert_eq(
    render(template, data),
    "<article><h2>Release</h2><p>Ready</p></article>",
  )
}

///|
test "fixture html card escapes body" {
  let template = "<article><p>{{body}}</p></article>"
  assert_eq(
    render(template, { "body": "<img src=x>" }),
    "<article><p>&lt;img src=x&gt;</p></article>",
  )
}

///|
test "fixture email list" {
  let template = "Hi {{user}},\n{{#tasks}}- {{title}} ({{status}})\n{{/tasks}}{{^tasks}}No tasks.\n{{/tasks}}"
  let data : Json = {
    "user": "Ops",
    "tasks": [
      { "title": "CI", "status": "green" },
      { "title": "Docs", "status": "review" },
    ],
  }
  assert_eq(render(template, data), "Hi Ops,\n- CI (green)\n- Docs (review)\n")
}

///|
test "fixture empty email list" {
  let template = "Hi {{user}},\n{{#tasks}}- {{title}}\n{{/tasks}}{{^tasks}}No tasks.\n{{/tasks}}"
  assert_eq(
    render(template, { "user": "Ops", "tasks": [] }),
    "Hi Ops,\nNo tasks.\n",
  )
}

///|
test "fixture localized greeting" {
  let template = "{{greeting}}, {{profile.name}}!"
  assert_eq(
    render(template, {
      "greeting": "你好",
      "profile": { "name": "开发者" },
    }),
    "你好, 开发者!",
  )
}

///|
test "fixture nested navigation" {
  let template = "{{#groups}}{{label}}:{{#links}}[{{title}}]{{/links}};{{/groups}}"
  let data : Json = {
    "groups": [
      { "label": "Docs", "links": [{ "title": "API" }, { "title": "FAQ" }] },
    ],
  }
  assert_eq(render(template, data), "Docs:[API][FAQ];")
}

///|
test "fixture partial page layout" {
  let template = "{{>header}}\nmain\n{{>footer}}"
  let partials = {
    "header": "<header>{{title}}</header>",
    "footer": "<footer>ok</footer>",
  }
  assert_eq(
    render_with_partials(template, { "title": "Home" }, partials),
    "<header>Home</header>\nmain\n<footer>ok</footer>",
  )
}

///|
test "fixture partial layout preserves line indentation" {
  let template = "page:\n  {{>body}}"
  let partials = { "body": "one\ntwo\nthree" }
  assert_eq(
    render_with_partials(template, {}, partials),
    "page:\n  one\n  two\n  three",
  )
}

///|
test "fixture report with missing optional field" {
  let template = "{{name}} {{description}}"
  assert_eq(render(template, { "name": "item" }), "item ")
}

///|
test "fixture report with raw trusted fragment" {
  let template = "<div>{{{trusted}}}</div>"
  assert_eq(
    render(template, { "trusted": "<em>trusted</em>" }),
    "<div><em>trusted</em></div>",
  )
}

///|
test "fixture repeated compiled rendering" {
  let template = compile("{{id}}:{{state}}")
  let documents : Array[Json] = [
    { "id": "a", "state": "new" },
    { "id": "b", "state": "done" },
    { "id": "c", "state": "queued" },
  ]
  let outputs = template.render_many(documents)
  assert_eq(outputs.length(), 3)
  assert_eq(outputs[1], "b:done")
}

///|
test "fixture custom delimiter report" {
  let template = "{{=<% %>=}}<%#items%><%name%>,<%/items%>"
  assert_eq(
    render(template, { "items": [{ "name": "a" }, { "name": "b" }] }),
    "a,b,",
  )
}

///|
test "fixture comments do not leak" {
  assert_eq(render("visible{{! internal ticket 123}}", {}), "visible")
}

///|
test "fixture boolean feature flag" {
  let template = "{{#enabled}}ON{{/enabled}}{{^enabled}}OFF{{/enabled}}"
  assert_eq(render(template, { "enabled": true }), "ON")
  assert_eq(render(template, { "enabled": false }), "OFF")
}

///|
test "fixture numeric counter" {
  assert_eq(render("completed={{count}}", { "count": 12 }), "completed=12")
}

///|
test "fixture unicode document" {
  let template = "标题：{{title}}\n作者：{{author}}"
  let data : Json = { "title": "MoonBit 模板", "author": "生态团队" }
  assert_eq(
    render(template, data),
    "标题：MoonBit 模板\n作者：生态团队",
  )
}

///|
test "fixture partial registry update" {
  let store = PartialStore::new()
  store.set("status", "draft")
  assert_eq(store.render("{{>status}}", {}), "draft")
  store.set("status", "published")
  assert_eq(store.render("{{>status}}", {}), "published")
}
