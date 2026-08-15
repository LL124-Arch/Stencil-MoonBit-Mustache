/// Rendering policies exposed to library consumers.

///|
/// Controls how a missing partial is handled.
pub(all) enum MissingPartialPolicy {
  /// Preserve the historical behavior and emit nothing.
  Empty
  /// Stop rendering with a deterministic error.
  Error
  /// Keep the original partial tag in the output.
  Preserve
} derive(Debug, Eq)

///|
/// Controls safety, compatibility, and resource limits for rendering.
pub(all) struct RenderOptions {
  escape_html : Bool
  standalone_lines : Bool
  max_nesting_depth : Int
  max_partial_depth : Int
  max_output_length : Int
  missing_partial : MissingPartialPolicy
  detect_partial_cycles : Bool
} derive(Debug, Eq)

///|
/// Construct the stable legacy-compatible defaults.
pub fn RenderOptions::default() -> RenderOptions {
  {
    escape_html: true,
    standalone_lines: true,
    max_nesting_depth: 256,
    max_partial_depth: 256,
    max_output_length: 0,
    missing_partial: MissingPartialPolicy::Empty,
    // Keep the historical renderer's depth error as the default. Cycle
    // diagnostics are available as an explicit safety policy below.
    detect_partial_cycles: false,
  }
}

///|
/// Enable or disable HTML escaping for normal variables.
pub fn RenderOptions::with_escape_html(
  self : RenderOptions,
  enabled : Bool,
) -> RenderOptions {
  { ..self, escape_html: enabled }
}

///|
/// Enable or disable standalone control-line normalization.
pub fn RenderOptions::with_standalone_lines(
  self : RenderOptions,
  enabled : Bool,
) -> RenderOptions {
  { ..self, standalone_lines: enabled }
}

///|
/// Set the maximum nested section depth. Zero means unlimited.
pub fn RenderOptions::with_max_nesting_depth(
  self : RenderOptions,
  limit : Int,
) -> RenderOptions {
  { ..self, max_nesting_depth: normalize_limit(limit) }
}

///|
/// Set the maximum recursive partial depth. Zero means unlimited.
pub fn RenderOptions::with_max_partial_depth(
  self : RenderOptions,
  limit : Int,
) -> RenderOptions {
  { ..self, max_partial_depth: normalize_limit(limit) }
}

///|
/// Set the maximum output length. Zero means unlimited.
pub fn RenderOptions::with_max_output_length(
  self : RenderOptions,
  limit : Int,
) -> RenderOptions {
  { ..self, max_output_length: normalize_limit(limit) }
}

///|
/// Select the missing-partial behavior.
pub fn RenderOptions::with_missing_partial(
  self : RenderOptions,
  policy : MissingPartialPolicy,
) -> RenderOptions {
  { ..self, missing_partial: policy }
}

///|
/// Enable or disable explicit partial-cycle diagnostics.
pub fn RenderOptions::with_partial_cycle_detection(
  self : RenderOptions,
  enabled : Bool,
) -> RenderOptions {
  { ..self, detect_partial_cycles: enabled }
}

///|
/// Read the escaping policy.
pub fn RenderOptions::escape_html(self : RenderOptions) -> Bool {
  self.escape_html
}

///|
/// Read the standalone-line policy.
pub fn RenderOptions::standalone_lines(self : RenderOptions) -> Bool {
  self.standalone_lines
}

///|
/// Read the maximum section depth.
pub fn RenderOptions::max_nesting_depth(self : RenderOptions) -> Int {
  self.max_nesting_depth
}

///|
/// Read the maximum partial depth.
pub fn RenderOptions::max_partial_depth(self : RenderOptions) -> Int {
  self.max_partial_depth
}

///|
/// Read the maximum output length.
pub fn RenderOptions::max_output_length(self : RenderOptions) -> Int {
  self.max_output_length
}

///|
/// Read the missing-partial policy.
pub fn RenderOptions::missing_partial(
  self : RenderOptions,
) -> MissingPartialPolicy {
  self.missing_partial
}

///|
/// Read the partial-cycle policy.
pub fn RenderOptions::detect_partial_cycles(self : RenderOptions) -> Bool {
  self.detect_partial_cycles
}

///|
fn normalize_limit(limit : Int) -> Int {
  if limit < 0 {
    0
  } else {
    limit
  }
}
