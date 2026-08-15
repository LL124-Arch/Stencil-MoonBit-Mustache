# Stencil Ecosystem Expansion Design

**Date:** 2026-08-15

**Goal:** Expand Stencil into a configurable, diagnosable, analyzable Mustache engine while preserving the existing public rendering API and restoring compatibility with MoonBit 0.10.3.

## Scope

The release adds four reusable capabilities:

1. `RenderOptions` controls escaping, standalone handling, resource limits, and missing-partial behavior.
2. `TemplateDiagnostic` and `TemplateStats` expose actionable compile-time information without changing the existing `TemplateError` constructor.
3. `PartialStore` centralizes partial registration, compilation, dependency analysis, cache statistics, and cycle-safe expansion.
4. The CLI exposes `render`, `analyze`, `compatibility`, and `benchmark` demonstrations that exercise the public APIs.

The existing `render`, `compile`, `Template::render`, `render_with_partials`, and `Template::render_with` APIs remain available. Existing defaults remain compatible: HTML escaping is enabled, missing partials render as empty output, and the historical non-raising methods preserve their behavior.

## Architecture

- `types.mbt` owns public data types and error values.
- `options.mbt` owns rendering policy and defaults.
- `diagnostics.mbt` owns source positions, diagnostics, and template statistics.
- `partials.mbt` owns reusable partial stores and cache metadata.
- `analysis.mbt` walks the AST without rendering and computes structural metrics.
- `render.mbt` keeps the renderer deterministic and receives policy/store state explicitly.
- `stencil.mbt` remains the small public facade and maps legacy calls to default options.

Resource limits are checked before recursive expansion and use explicit `TemplateError` messages. Partial cycles are detected by an active-name stack, while repeated non-cyclic partials remain cacheable. The AST is still private to the implementation package; public analysis returns value types designed for tooling and documentation.

## Testing strategy

Tests are added before implementation for:

- default and custom rendering policies,
- escaped/raw output,
- section and partial limits,
- missing partial policies,
- partial cycles and cache hits,
- template statistics and dependency order,
- line/column diagnostics,
- Unicode, CRLF, delimiter, malformed-template, and long-input boundaries,
- CLI analysis and compatibility output.

The release must pass `moon fmt --check`, `moon check --deny-warn --target all`, all supported target tests, the benchmark smoke test, and the repository acceptance script under MoonBit 0.10.3 and the current latest toolchain.

## Acceptance evidence

The README, CHANGELOG, performance report, and acceptance checklist will document the new APIs, compatibility guarantees, benchmark workloads, and reproducible commands. GitHub and GitLink will receive the same source tree and CI configuration after the primary repository is verified.
