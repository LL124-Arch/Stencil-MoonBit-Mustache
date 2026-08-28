# Stencil

> A small, safe, composable Mustache-style template engine for MoonBit.

[![MoonBit](https://img.shields.io/badge/Language-MoonBit-orange.svg)](https://www.moonbitlang.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub CI](https://img.shields.io/badge/CI-GitHub%20Actions-success.svg)](.github/workflows/ci.yml)
[![GitLink CI](https://img.shields.io/badge/CI-GitLink-success.svg)](.gitlink/workflows/ci.yml)

Stencil brings familiar Mustache templates to MoonBit with a focused API, safe HTML escaping, bounded parsing, diagnostics, and reusable partial/template registries.

## Why Stencil

| Built for | What you get |
| --- | --- |
| Safe output | `{{name}}` escapes HTML by default; raw output is always explicit. |
| Small surfaces | Start with `render` and `compile`; opt into catalogs and policies when you need them. |
| Predictable systems | Limits, deterministic errors, dependency inspection, and failure-preserving batch reports. |
| MoonBit teams | Native tests, CI, benchmarks, generated interfaces, and no filesystem/network assumptions. |

## Feature map

- Variables: `{{name}}`, raw variables `{{{html}}}` and `{{&html}}`
- Sections: `{{#items}}...{{/items}}`, inverted sections, list iteration with `{{.}}`
- Contexts: dotted paths such as `{{user.profile.name}}`
- Composition: partials with standalone indentation propagation
- Syntax: comments, standalone control lines, and delimiter changes
- Operations: render limits, missing-partial policies, partial cycle detection
- Tooling: diagnostics, AST metrics, compatibility corpus, catalog reports, and benchmarks

## Install

```bash
moon add LL124-Arch/stencil
```

Or import the package directly:

```moonbit
import {
  "LL124-Arch/stencil/src" @stencil,
}
```

Package page: [LL124-Arch/stencil on Mooncakes](https://mooncakes.io/docs/LL124-Arch/stencil)

## Quick start

```moonbit
fn main {
  let template = "Hello {{name}}! Welcome to {{project}}."
  let data : Json = {
    "name": "Developer",
    "project": "Stencil",
  }

  try {
    println(@stencil.render(template, data))
  } catch {
    @stencil.TemplateError(msg) => println("Template error: \{msg}")
  }
}
```

```text
Hello Developer! Welcome to Stencil.
```

## CLI: Stencil Studio

The repository includes a compact terminal tour of the engine. It uses the same public API as applications do and presents template, data, and rendered output as separate sections.

```bash
moon run cli
moon run cli -- help
moon run cli -- analyze
moon run cli -- compatibility
moon run cli -- benchmark
```

The default demo highlights HTML-safe interpolation, sections, and the MoonBit-native workflow. `benchmark` prints a deterministic checksum so timing noise can be separated from correctness regressions.

## API at a glance

```moonbit
let compiled = @stencil.compile("User: {{name}}")
println(compiled.render({ "name": "Alice" }))
println(compiled.render({ "name": "Bob" }))
```

- `render(template, data)` compiles and renders in one step.
- `compile(source)` creates a reusable `Template`.
- `Template::render(template, data)` renders precompiled templates.
- `render_with_partials(template, data, partials)` supplies named partial sources.
- `Template::render_with(template, data, partials)` combines reuse and partials.

### Checked rendering

`RenderOptions` exposes explicit policies for escaping, nesting/output limits, missing partials, and recursive partial detection. `MissingPartialPolicy::Empty` preserves legacy behavior; `Error` is recommended for production validation, and `Preserve` suits multi-pass pipelines.

```moonbit
let options = @stencil.RenderOptions::default()
  .with_max_output_length(1_000_000)
  .with_missing_partial(@stencil.MissingPartialPolicy::Error)
let html = @stencil.render_with_options_and_partials(template, data, partials, options)
```

### Registries and reports

`PartialStore` centralizes named partials with `set`, `remove`, `names`, `validate`, `dependencies`, `compile_all`, and option-aware rendering.

`TemplateCatalog` manages named sources, lazy compilation, revision numbers, dependency edges, health reports, and cache invalidation. It is useful for page bundles, email layouts, documentation builds, and configuration generators. See [catalog usage and operational notes](docs/catalog.md).

`diagnose(source)` returns stable severity, message, byte index, line, and column fields without raising. `compile(source).stats()` reports node counts, variables, sections, partials, depth, delimiter use, and complexity.

## Compatibility boundaries

Stencil targets a practical, documented subset of the [official Mustache manual](https://mustache.github.io/mustache.5.html): variables, raw variables, truthy/falsey sections, lists, nested contexts, inverted sections, partials, comments, dotted paths, standalone control lines, and delimiter changes.

Stable boundaries callers can rely on:

- Missing keys render as empty strings.
- Arrays and objects stringify as `[Array]` and `[Object]` outside traversal.
- Legacy APIs render missing partials as empty strings; configured APIs can error or preserve the tag.
- Parser sections and partial expansion default to 256 nested levels; render-time limits are configurable.
- Lambdas, expression evaluation, filesystem partial loading, and dynamic partial names are out of scope.

See the full [Mustache compatibility notes](docs/mustache-compatibility.md).

## Development

Recommended local verification loop:

```bash
moon fmt --check
moon check --deny-warn --target all
moon build --target wasm,wasm-gc,js
moon info --target all
moon test --deny-warn --target wasm,wasm-gc,js
moon test --deny-warn --target native
moon run cli -- benchmark
```

For performance details, run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\benchmark.ps1 -Iterations 5
```

The acceptance self-check is available at `scripts\verify_acceptance.ps1`. CI definitions live in [.github/workflows/ci.yml](.github/workflows/ci.yml) and [.gitlink/workflows/ci.yml](.gitlink/workflows/ci.yml).

## License

MIT. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
