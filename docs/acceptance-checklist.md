# OSC2026 Acceptance Checklist

Last updated: 2026-07-11

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
| License | `LICENSE` |
| Commit history | `git log --oneline`, `scripts/verify_acceptance.ps1` |
| Repository self-check | `scripts/verify_acceptance.ps1` |

## Notes for reviewers

- MoonBit CLI `moonc v0.10.3` or newer exposes strict warning mode on `moon check` and `moon test`, but not on `moon fmt` or `moon info`.
- This repository therefore uses the strict equivalents recommended by the current CLI help:
  - `moon fmt --check`
  - `moon build --target wasm,wasm-gc,js`
  - `moon info --target all`
  - `git diff --ignore-all-space --exit-code` (ignores toolchain-only whitespace churn)
  - `moon check --deny-warn --target all`
  - `moon test --deny-warn --target ...`

These steps are enforced both in CI and in the local acceptance script.
