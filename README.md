# Stencil

[![MoonBit](https://img.shields.io/badge/Language-MoonBit-orange.svg)](https://www.moonbitlang.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub CI](https://img.shields.io/badge/CI-GitHub%20Actions-success.svg)](.github/workflows/ci.yml)
[![GitLink CI](https://img.shields.io/badge/CI-GitLink-success.svg)](.gitlink/workflows/ci.yml)

Stencil is a lightweight Mustache-style template engine for MoonBit. It focuses on a practical, documented core: variable interpolation, sections, inverted sections, partials, comments, dotted-path lookup, changing delimiters, and safe HTML escaping by default.

## Why this project

- Small API surface: `render`, `compile`, and partial-aware rendering helpers.
- Safe-by-default output: `{{name}}` escapes HTML automatically.
- Practical Mustache coverage: sections, inverted sections, lists, object contexts, comments, raw variables, and partials.
- Predictable edge behavior: standalone control lines, CRLF input, bounded nesting, and deterministic errors.
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
- Standalone comments and section control lines
- Delimiter changes: `{{=<% %>=}}<%name%>`
- Bounded parser and partial expansion depth (256 levels)
- Configurable render limits, missing-partial policies, and cycle detection
- `PartialStore` for reusable partial registries, validation, dependency inspection, and startup compilation
- Diagnostics and structural metrics for editors, CI, and acceptance review
- Compatibility corpus and reproducible HTML catalog benchmark

## Installation

Add the package to your MoonBit module:

```bash
moon add LL124-Arch/stencil
```

Package page: [LL124-Arch/stencil on Mooncakes](https://mooncakes.io/docs/LL124-Arch/stencil)

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

### `RenderOptions` and checked rendering

`render_with_options` and `render_with_options_and_partials` expose explicit
policies for HTML escaping, nesting/partial/output limits, missing partials,
and recursive partial detection. `MissingPartialPolicy::Empty` preserves the
legacy behavior; `Error` is recommended for production validation and
`Preserve` is useful for multi-pass pipelines.

```moonbit
let options = @stencil.RenderOptions::default()
  .with_max_output_length(1_000_000)
  .with_missing_partial(@stencil.MissingPartialPolicy::Error)
let html = @stencil.render_with_options_and_partials(template, data, partials, options)
```

### `PartialStore`

`PartialStore` centralizes named sources and supports `set`, `remove`, `names`,
`validate`, `dependencies`, `compile_all`, and option-aware rendering. This
provides a deterministic application boundary without introducing filesystem
or network access into the library.

### Diagnostics and analysis

`diagnose(source)` returns stable severity, message, byte index, line, and
column fields without raising. `compile(source).stats()` reports node counts,
variables, sections, partials, depth, delimiter use, and a complexity score.
The CLI exposes the same evidence:

```bash
moon run cli -- analyze
moon run cli -- compatibility
moon run cli -- benchmark
```

## Mustache Compatibility Notes

Stencil intentionally supports a practical core instead of every corner of the full Mustache spec.

The compatibility target is the [official Mustache manual](https://mustache.github.io/mustache.5.html). The exact implemented subset, intentional deviations, and unsupported host-dependent extensions are recorded in [docs/mustache-compatibility.md](docs/mustache-compatibility.md).

Supported behavior:

- Variables and raw variables
- Truthy and falsey section rendering
- List iteration with `{{.}}`
- Nested object contexts
- Inverted sections
- Partials
- Comments
- Dotted-path lookup
- Standalone comments and section control lines using the default delimiters
- Delimiter changes such as `{{=<% %>=}}<%name%>`

Current behavior boundaries:

- Missing keys render as empty strings
- Arrays stringify as `[Array]` outside section iteration
- Objects stringify as `[Object]` outside section traversal
- Missing partials render as empty strings only through legacy APIs; configured APIs can error or preserve the tag
- Invalid partial source is ignored by legacy `render_with_partials` / `Template::render_with`, while configured APIs report it
- Parser sections and partial expansion default to 256 nested levels; `RenderOptions` can lower or remove the render-time limits
- Mustache lambdas, expression evaluation, filesystem partial loading, and dynamic partial names are outside the current scope

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
moon build --target wasm,wasm-gc,js
moon info --target all
git diff --ignore-blank-lines --exit-code
moon test --deny-warn --target wasm,wasm-gc,js
```

If a system C compiler is available, also run:

```bash
moon test --deny-warn --target native
moon build --target native
```

## CI and Toolchain Notes

The official OSC2026 feedback asked for strict formatting, interface generation, type checking, and tests under the latest MoonBit toolchain.

With MoonBit CLI `moonc v0.10.3` or newer, strict warning mode is available on
`moon check` and `moon test`, but not exposed on `moon fmt` or `moon info`.
Hosted CI runs `moon fmt --check src` because the 0.10.3 formatter accepts the
executable package metadata in `cli/moon.pkg`, while newer formatters may
rewrite that metadata. The complete CLI package remains covered by check,
build, interface generation, and multi-target tests:

- `moon fmt --check src`
- `moon check --deny-warn --target all`
- `moon build --target wasm,wasm-gc,js`
- `moon info --target all`
- `git diff --ignore-blank-lines --exit-code` (interface drift check; ignores toolchain-only blank-line churn)
- `moon test --deny-warn --target ...`
- `moon run cli -- benchmark` (deterministic benchmark smoke check)

The local acceptance script additionally runs full `moon fmt --check` under the
pinned 0.10.3 toolchain.

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
- MoonBit source scale and test-suite floor,
- local verification commands.

See [docs/acceptance-checklist.md](docs/acceptance-checklist.md) for the requirement-to-evidence mapping used in this repository.

## Performance Baseline

The reproducible benchmark uses one compiled-template workload: the CLI compiles
the four-item catalog template once and renders it 200 times. The PowerShell
wrapper additionally records end-to-end `moon run` startup cost. It is documented in
[docs/performance.md](docs/performance.md) and can be run with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\benchmark.ps1 -Iterations 5
```

The CLI reports the workload, iteration count, output length, checksum, and a
consistency flag so correctness regressions are distinguishable from timing noise.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE)
and [NOTICE](NOTICE) for the project attribution and compliance note.
