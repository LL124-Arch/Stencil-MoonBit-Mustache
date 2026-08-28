# Stencil Studio CLI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the MoonBit repository a polished, discoverable CLI demo and a product-oriented README without changing the rendering API.

**Architecture:** Keep all behavior in the existing `cli/main.mbt` entrypoint, with pure string helpers for stable output and a small command dispatcher. Rewrite documentation around the same public API and CLI commands so code and docs remain aligned.

**Tech Stack:** MoonBit 0.10.9, existing Stencil library API, Markdown.

---

### Task 1: Establish the CLI presentation contract

**Files:**
- Modify: `cli/main.mbt`
- Test: `cli/main_wbtest.mbt`

- [ ] **Step 1: Write the failing test**

Add tests for `command_help()` containing the command names and `demo_output()` containing the three output sections.

- [ ] **Step 2: Run the test to verify it fails**

Run `moon test cli --target native`; expected failure because the helpers do not exist.

- [ ] **Step 3: Implement minimal helpers**

Add pure helpers returning strings, then make `main` print them. Keep existing command functions and route `help`/`demo` through the new presentation.

- [ ] **Step 4: Run the test to verify it passes**

Run `moon test cli --target native`; expected PASS.

### Task 2: Rework repository-facing documentation

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Replace the README structure**

Lead with the value proposition, add a compact capability grid, make quick start and CLI discovery prominent, and retain the complete API/compatibility/development details.

- [ ] **Step 2: Add the release note**

Add an unreleased entry describing the Stencil Studio CLI and README information architecture update.

- [ ] **Step 3: Check documentation examples**

Run `rg -n "moon run cli|render_with_partials|Template::render" README.md` and verify each documented command/API matches the code.

### Task 3: Format and verify

**Files:**
- Modify: generated MoonBit interface files only if the toolchain requires it.

- [ ] **Step 1: Format and type-check**

Run `moon fmt --check` and `moon check --deny-warn --target all`.

- [ ] **Step 2: Run behavior checks**

Run `moon test --deny-warn --target native`, `moon run cli`, `moon run cli -- help`, and `moon run cli -- benchmark`.

- [ ] **Step 3: Review the diff**

Run `git diff --check` and inspect `git diff --stat` plus the final CLI output for accidental scope expansion.

