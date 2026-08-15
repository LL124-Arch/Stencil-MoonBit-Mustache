# Mustache Compatibility Scope

Stencil follows the core behavior described by the [official Mustache manual](https://mustache.github.io/mustache.5.html). The reference is used as a behavioral guide; Stencil is an independent MoonBit implementation and does not copy Mustache source code.

## Implemented core

- escaped and raw variables, including dotted names and the implicit iterator;
- truthy and inverted sections with nested JSON contexts and list iteration;
- comments, partials, standalone control lines, partial indentation, and delimiter changes;
- deterministic error diagnostics for malformed tags, mismatched sections, invalid delimiters, and configured resource limits.

## Explicit boundaries

The following behavior is intentionally outside the current API contract:

- lambda execution and arbitrary expression evaluation;
- filesystem or network-backed partial loading;
- dynamically computed partial names;
- non-default standalone semantics for delimiter-control lines.

Missing values and missing partials also have documented behavior rather than silently depending on implementation details. Legacy APIs preserve empty-string compatibility, while `RenderOptions` can request an error or preserve an unresolved partial tag. See the [README compatibility notes](../README.md#mustache-compatibility-notes) and the option-aware tests in `src/`.

This scope makes the compatibility claim reviewable: the project targets a practical, dependency-free Mustache core and does not claim full support for extensions that require host callbacks, I/O, or an expression runtime.
