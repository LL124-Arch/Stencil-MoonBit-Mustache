# Stencil

[![MoonBit](https://img.shields.io/badge/Language-MoonBit-orange.svg)](https://www.moonbitlang.com/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![GitHub CI](https://img.shields.io/badge/CI-GitHub%20Actions-success.svg)](.github/workflows/ci.yml)
[![GitLink CI](https://img.shields.io/badge/CI-GitLink-success.svg)](.gitlink/workflows/ci.yml)

Stencil is a lightweight Mustache-style template engine for MoonBit. It focuses on the subset of features that are most useful in application code: variable interpolation, sections, inverted sections, partials, comments, dotted-path lookup, and safe HTML escaping by default.

## Why this project

- Small API surface: `render`, `compile`, and partial-aware rendering helpers.
- Safe-by-default output: `{{name}}` escapes HTML automatically.
- Practical Mustache coverage: sections, inverted sections, lists, object contexts, comments, raw variables, and partials.
- MoonBit-first maintenance: tests, CI, changelog, and repository self-checks are part of the project itself.

## Feature Summary

- Escaped variables: `{{name}}`
- Raw variables: `{{{html}}}` and `{{&html}}`
- Sections: `{{#items}}...{{/items}}`
- Inverted sections: `{{^items}}...{{/items}}`
- Dotted-path lookup: `{{user.profile.name}}`
- Implicit iterator for lists: `{{.}}`
- Partials with standalone indentation propagation
- Comment tags: `{{! ignored }}`

## Installation

Add the package to your MoonBit module:

```bash
moon add LL124-Arch/stencil
```

Or import it directly in code:

```moonbit
import {
  "LL124-Arch/stencil/src" @stencil,
}
```

## Quick Start

```moonbit
fn main {
  let template = "Hello {{name}}! Welcome to {{project}}."
  let data : Json = {
    "name": "Developer",
    "project": "Stencil",
  }

  try {
    let result = @stencil.render(template, data)
    println(result)
  } catch {
    @stencil.TemplateError(msg) => println("Template error: \{msg}")
  }
}
```

Output:

```text
Hello Developer! Welcome to Stencil.
```

## API

### `render(template : String, data : Json) -> String raise TemplateError`

Compile and render a template in one step.

### `compile(source : String) -> Template raise TemplateError`

Compile a template once and reuse it with different JSON inputs.

### `Template::render(self : Template, data : Json) -> String`

Render a precompiled template with the provided context.

### `render_with_partials(template : String, data : Json, partials : Map[String, String]) -> String raise TemplateError`

Render a template while supplying partial sources by name.

### `Template::render_with(self : Template, data : Json, partials : Map[String, String]) -> String`

Render a precompiled template with named partial sources.

## Mustache Compatibility Notes

Stencil intentionally supports a practical core instead of every corner of the full Mustache spec.

Supported behavior:

- Variables and raw variables
- Truthy and falsey section rendering
- List iteration with `{{.}}`
- Nested object contexts
- Inverted sections
- Partials
- Comments
- Dotted-path lookup

Current behavior boundaries:

- Missing keys render as empty strings
- Arrays stringify as `[Array]` outside section iteration
- Objects stringify as `[Object]` outside section traversal
- Missing partials currently render as empty strings
- Invalid partial source is ignored by `render_with_partials` / `Template::render_with`

These boundaries are documented so callers can rely on stable behavior instead of guessing from implementation details.

## Examples

### HTML-safe output

```moonbit
let tpl = "<p>{{content}}</p>"
let result = @stencil.render(tpl, { "content": "<script>alert(1)</script>" })
// <p>&lt;script&gt;alert(1)&lt;/script&gt;</p>
```

### Reusing a compiled template

```moonbit
let tpl = @stencil.compile("User: {{name}}")
println(tpl.render({ "name": "Alice" }))
println(tpl.render({ "name": "Bob" }))
```

### Partials with indentation

```moonbit
let template = "items:\n  {{>item}}\ndone"
let partials = {
  "item": "- {{name}}\n- ready",
}
let data : Json = { "name": "Stencil" }
let result = @stencil.render_with_partials(template, data, partials)
```

Output:

```text
items:
  - Stencil
  - ready
done
```

### Production-style email snippet

```moonbit
let template =
  "Hello {{user.name}},\n" +
  "{{#items}}- {{title}}: {{status}}\n{{/items}}" +
  "{{^items}}No pending tasks.\n{{/items}}"

let data : Json = {
  "user": { "name": "Ops Team" },
  "items": [
    { "title": "CI", "status": "green" },
    { "title": "Release", "status": "pending" },
  ],
}
```

## CLI Demo

This repository includes a small runnable CLI example:

```bash
moon run cli
```

## Development

Recommended local verification loop:

```bash
moon fmt --check
moon check --deny-warn --target all
moon info --target all
git diff --exit-code
moon test --deny-warn --target wasm,wasm-gc,js
```

If a system C compiler is available, also run:

```bash
moon test --deny-warn --target native
```

## CI and Toolchain Notes

The official OSC2026 feedback asked for strict formatting, interface generation, type checking, and tests under the latest MoonBit toolchain.

With current MoonBit CLI `moonc v0.10.3`, strict warning mode is available on `moon check` and `moon test`, but not exposed on `moon fmt` or `moon info`. This repository therefore enforces the current strict equivalents in CI:

- `moon fmt --check`
- `moon check --deny-warn --target all`
- `moon info --target all`
- `git diff --exit-code`
- `moon test --deny-warn --target ...`

Both GitHub Actions and GitLink CI are included:

- [GitHub workflow](.github/workflows/ci.yml)
- [GitLink workflow](.gitlink/workflows/ci.yml)

## OSC2026 Self-Check

For competition maintenance, run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify_acceptance.ps1
```

The script checks:

- repository structure,
- README and license presence,
- GitHub and GitLink CI files,
- commit history summary,
- default branch visibility,
- MoonBit source scale,
- local verification commands.

See [docs/acceptance-checklist.md](docs/acceptance-checklist.md) for the requirement-to-evidence mapping used in this repository.

## License

This project is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.
