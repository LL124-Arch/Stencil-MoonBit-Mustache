# OSC2026 Acceptance Checklist

Last updated: 2026-08-15

This checklist maps the public OSC2026 acceptance baseline to concrete evidence in this repository.

## Official baseline

The official MoonBit OSC2026 site source currently states that accepted projects should:

- use MoonBit as the primary implementation language,
- keep the repository public,
- provide a clear README,
- provide runnable examples,
- provide CI,
- provide tests,
- publish on Mooncakes,
- keep commit history and open-source metadata auditable.
- maintain a meaningful project scope and effective MoonBit implementation scale.

Reference sources:

- Official site source: `moonbitlang/OSC2026/main/main.mbt`
- Official website: <https://moonbitlang.github.io/OSC2026/>

## Repository evidence

| Requirement | Evidence |
| --- | --- |
| MoonBit is the main language | `src/*.mbt`, `cli/main.mbt`, `moon.mod` |
| Public repository metadata | `moon.mod` repository field points to GitHub mirror |
| Clear README | `README.md` |
| Runnable example | `cli/main.mbt`, README quick-start examples |
| GitHub CI | `.github/workflows/ci.yml` |
| GitLink CI | `.gitlink/workflows/ci.yml` |
| Tests | `src/*_wbtest.mbt` |
| Compatibility and boundary tests | `src/compatibility.mbt`, compatibility matrix, fixture/security/limits tests |
| Configurable production API | `src/options.mbt`, `src/partials.mbt`, `src/diagnostics.mbt`, `src/analysis.mbt` |
| Named-template application pipeline | `src/catalog*.mbt`, `docs/catalog.md`, catalog tests |
| Performance evidence | `scripts/benchmark.ps1`, `cli/main.mbt`, `docs/performance.md` |
| MIT license and package metadata | `LICENSE`, `moon.mod`, README license badge |
| Attribution and third-party notice | `NOTICE` |
| Commit history | `git log --oneline`, `scripts/verify_acceptance.ps1` |
| Repository self-check | `scripts/verify_acceptance.ps1` |
| Proposal and usage consistency | `项目申报书.md`, `README.md`, `CHANGELOG.md` |
| Mustache reference and scope | `docs/mustache-compatibility.md`, README compatibility notes |

## Notes for reviewers

- MoonBit CLI `moonc v0.10.3` or newer exposes strict warning mode on `moon check` and `moon test`, but not on `moon fmt` or `moon info`.
- This repository therefore uses the strict equivalents recommended by the current CLI help:
  - local acceptance: `moon fmt --check`
  - hosted CI: `moon fmt --check src` (the MoonBit 0.10.3 formatter accepts the
    executable package metadata required by this repository; newer formatters
    may rewrite that metadata, so CI keeps the source formatter check stable)
  - `moon build --target wasm,wasm-gc,js`
  - `moon info --target all`
  - `git diff --ignore-blank-lines --exit-code` (ignores toolchain-only blank-line churn)
  - `moon check --deny-warn --target all`
  - `moon test --deny-warn --target ...`
  - `moon run cli -- benchmark`

The CI source-format scope does not weaken executable validation: `moon check`,
`moon build`, `moon info`, interface generation, and multi-target tests still
discover and validate the complete `cli` package.

These steps are enforced both in CI and in the local acceptance script.

## Final review evidence

- The current test suite contains 246 deterministic tests covering the
  documented Mustache core, named-template batches, malformed input, Unicode, CRLF, long text, deep
  sections, large lists, partial indentation, delimiter changes, and recursive
  partial limits.
- The benchmark uses a four-item HTML catalog workload, 200 compiled renders,
  a byte-length total, and a deterministic weighted checksum. The CLI emits
  machine-readable workload, iteration, output length, checksum, and consistency.
- GitHub and GitLink are maintained as synchronized public mirrors. The final
  review must check both remote HEADs, default branches, single-contributor
  histories, and the Mooncakes metadata after the release commit.
