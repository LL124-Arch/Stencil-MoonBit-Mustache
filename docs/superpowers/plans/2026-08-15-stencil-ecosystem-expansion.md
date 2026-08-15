# Stencil Ecosystem Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Add meaningful rendering, diagnostics, analysis, partial-management, CLI, and compatibility capabilities while bringing the effective MoonBit implementation toward 4,000 lines.

**Architecture:** Preserve the existing facade APIs and route them through default `RenderOptions`. Add focused public value types for policies, diagnostics, statistics, and partial stores; keep AST traversal and resource checks inside the `src` package. Use the GitHub clone as the primary implementation tree, then synchronize the verified tree to GitLink.

**Tech Stack:** MoonBit 0.10.3-compatible package metadata, MoonBit core JSON/maps/arrays, PowerShell benchmark and acceptance scripts, GitHub/GitLink CI.

---

### Task 1: Restore MoonBit 0.10.3 CLI compatibility

**Files:**
- Modify: `cli/moon.pkg`
- Test: `scripts/verify_acceptance.ps1`

- [ ] Replace `pkgtype(kind: "executable")` with `options("is-main": true)`.
- [ ] Run `moon fmt --check` and confirm package discovery succeeds under `moonc v0.10.3`.
- [ ] Run `moon check --deny-warn --target all`.

### Task 2: Add failing tests for render policies and diagnostics

**Files:**
- Create: `src/options_wbtest.mbt`
- Create: `src/diagnostics_wbtest.mbt`

- [ ] Test HTML escaping override, standalone-line policy, resource limits, missing-partial policy, and malformed-template diagnostics.
- [ ] Run the targeted tests and confirm they fail because the new APIs do not exist.

### Task 3: Implement policy and diagnostic types

**Files:**
- Create: `src/options.mbt`
- Create: `src/diagnostics.mbt`
- Modify: `src/types.mbt`
- Modify: `src/stencil.mbt`

- [ ] Add `RenderOptions`, `MissingPartialPolicy`, `TemplatePosition`, and `TemplateDiagnostic` with stable constructors and `Show` implementations.
- [ ] Add `Template::render_with_options` and `render_with_options` while preserving legacy defaults.
- [ ] Add checked resource-limit errors without changing `TemplateError(String)`.
- [ ] Run focused tests and then `moon fmt --check`.

### Task 4: Add partial store and analysis APIs

**Files:**
- Create: `src/partials.mbt`
- Create: `src/analysis.mbt`
- Create: `src/partials_wbtest.mbt`
- Create: `src/analysis_wbtest.mbt`
- Modify: `src/render.mbt`

- [ ] Implement `PartialStore` registration, compiled cache, dependency listing, active-cycle detection, and hit/miss counters.
- [ ] Implement `TemplateStats` AST traversal for variables, sections, raw variables, partials, delimiters, nodes, and maximum depth.
- [ ] Route partial-aware public rendering through the store.
- [ ] Add tests for cache hits, missing policies, cycles, dependency order, and structural metrics.

### Task 5: Extend CLI and benchmark workloads

**Files:**
- Modify: `cli/main.mbt`
- Modify: `cli/moon.pkg`
- Create: `cli/cli_wbtest.mbt` if supported by package layout
- Modify: `scripts/benchmark.ps1`

- [ ] Add deterministic `analyze`, `compatibility`, and policy demonstrations.
- [ ] Add HTML, email, Markdown, and nested-partial benchmark workloads with checksum validation.
- [ ] Keep `moon run cli -- benchmark` machine-readable and backward compatible.

### Task 6: Expand documentation and acceptance checks

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/performance.md`
- Modify: `docs/acceptance-checklist.md`
- Modify: `scripts/verify_acceptance.ps1`
- Modify: `.github/workflows/ci.yml`
- Modify: `.gitlink/workflows/ci.yml`

- [ ] Document new APIs, defaults, limits, diagnostics, partial store, CLI commands, and compatibility matrix.
- [ ] Add source-scale, package metadata, remote identity, and generated-interface checks to the acceptance script.
- [ ] Keep GitHub and GitLink workflows identical and include the compatibility smoke test.

### Task 7: Full verification and mirror synchronization

- [ ] Run formatting, strict checks, builds, generated-interface diff, tests, native tests where available, CLI benchmark, and acceptance script under MoonBit 0.10.3.
- [ ] Repeat the same checks with the latest installed toolchain.
- [ ] Verify Mooncakes package metadata and version.
- [ ] Verify identical tree IDs and clean default branches in both repositories.
- [ ] Commit the primary tree, synchronize the exact tree to GitLink with the creator identity, and re-check both remotes.
