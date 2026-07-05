# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- Core mustache specification support (Variables, Sections, Inverted Sections, Partials, Comments).
- Command line interface for template rendering.
- comprehensive bilingual README.md and usage documentation.
- Project proposal for 2026 MoonBit CCF Open Source Innovation Competition.
