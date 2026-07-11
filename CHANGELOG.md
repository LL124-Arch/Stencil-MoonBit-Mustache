# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Acceptance self-check script at `scripts/verify_acceptance.ps1` for OSC2026 repository audits.
- Additional parser, scanner, and rendering tests for partial indentation and failure cases.
- Acceptance checklist documentation that maps official OSC2026 requirements to repository evidence.

### Changed
- Rewrote `README.md` to remove garbled text and document APIs, compatibility boundaries, examples, and verification steps clearly.
- Upgraded GitHub and GitLink CI to a multi-platform workflow with strict `moon check`, formatting checks, interface generation checks, and test execution.
- Implemented actual standalone partial indentation handling so the documented Mustache behavior matches the runtime.

## [0.1.0] - 2026-06-30 (Final Project Closure)

### Added
- GitHub/GitLink Actions CI automation for `moon check` and `moon test`.
- `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md` to establish open-source community standards.
- Advanced edge case tests (deeply nested sections, falsey values) to `stencil_wbtest.mbt`.

### Changed
- Refactored `types.mbt` to resolve MoonBit compiler warnings regarding deprecated `derive(Show)`.
- Updated GitHub remote URLs and Markdown links in documentation and Proposal to match the new repository name.
- Optimized `.gitignore` to keep the Git tree clean from local build artifacts like PDFs and HTMLs.

## [0.0.1] - 2026-06-13

### Added
- Initial release of Stencil Engine for MoonBit.
- Core mustache specification support (variables, sections, inverted sections, partials, comments).
- Command line interface for template rendering.
- Bilingual README and usage documentation.
- Project proposal for the 2026 MoonBit CCF Open Source Innovation Competition.
