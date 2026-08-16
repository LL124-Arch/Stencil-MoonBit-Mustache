/// Batch rendering primitives for pages, mail merge, documentation builds,
/// and other applications that render many named documents in one pass.

///|
/// A named rendering request. Jobs are values so callers can build them from
/// queues, migration scripts, or application records without coupling those
/// records to the catalog implementation.
pub(all) struct CatalogRenderJob {
  template_name : String
  data : Json
} derive(Debug)

///|
pub fn CatalogRenderJob::new(
  template_name : String,
  data : Json,
) -> CatalogRenderJob {
  { template_name, data }
}

///|
pub fn CatalogRenderJob::template_name(self : CatalogRenderJob) -> String {
  self.template_name
}

///|
pub fn CatalogRenderJob::data(self : CatalogRenderJob) -> Json {
  self.data
}

///|
/// One successful output retained by a batch report.
pub(all) struct CatalogRenderOutput {
  template_name : String
  content : String
  length : Int
  checksum : Int
  job_index : Int
} derive(Debug)

///|
pub fn CatalogRenderOutput::template_name(self : CatalogRenderOutput) -> String {
  self.template_name
}

///|
pub fn CatalogRenderOutput::content(self : CatalogRenderOutput) -> String {
  self.content
}

///|
pub fn CatalogRenderOutput::length(self : CatalogRenderOutput) -> Int {
  self.length
}

///|
pub fn CatalogRenderOutput::checksum(self : CatalogRenderOutput) -> Int {
  self.checksum
}

///|
pub fn CatalogRenderOutput::job_index(self : CatalogRenderOutput) -> Int {
  self.job_index
}

///|
/// A failed job retained alongside successful outputs.
pub(all) struct CatalogRenderFailure {
  template_name : String
  message : String
  job_index : Int
} derive(Debug)

///|
pub fn CatalogRenderFailure::template_name(
  self : CatalogRenderFailure,
) -> String {
  self.template_name
}

///|
pub fn CatalogRenderFailure::message(self : CatalogRenderFailure) -> String {
  self.message
}

///|
pub fn CatalogRenderFailure::job_index(self : CatalogRenderFailure) -> Int {
  self.job_index
}

///|
/// A deterministic summary of a batch render operation.
pub(all) struct CatalogRenderReport {
  total_jobs : Int
  success_count : Int
  failure_count : Int
  total_output_length : Int
  checksum : Int
  outputs : Array[CatalogRenderOutput]
  failures : Array[CatalogRenderFailure]
} derive(Debug)

///|
pub fn CatalogRenderReport::total_jobs(self : CatalogRenderReport) -> Int {
  self.total_jobs
}

///|
pub fn CatalogRenderReport::success_count(self : CatalogRenderReport) -> Int {
  self.success_count
}

///|
pub fn CatalogRenderReport::failure_count(self : CatalogRenderReport) -> Int {
  self.failure_count
}

///|
pub fn CatalogRenderReport::total_output_length(
  self : CatalogRenderReport,
) -> Int {
  self.total_output_length
}

///|
pub fn CatalogRenderReport::checksum(self : CatalogRenderReport) -> Int {
  self.checksum
}

///|
pub fn CatalogRenderReport::outputs(
  self : CatalogRenderReport,
) -> Array[CatalogRenderOutput] {
  self.outputs
}

///|
pub fn CatalogRenderReport::failures(
  self : CatalogRenderReport,
) -> Array[CatalogRenderFailure] {
  self.failures
}

///|
pub fn CatalogRenderReport::is_complete(self : CatalogRenderReport) -> Bool {
  self.failure_count == 0 && self.success_count == self.total_jobs
}

///|
pub fn CatalogRenderReport::summary(self : CatalogRenderReport) -> String {
  let jobs = self.total_jobs
  let success = self.success_count
  let failures = self.failure_count
  let output_length = self.total_output_length
  let checksum = self.checksum
  "jobs=\{jobs}, success=\{success}, failures=\{failures}, " +
  "output_length=\{output_length}, checksum=\{checksum}"
}

///|
/// Render one named template using a shared partial map and policy.
pub fn TemplateCatalog::render_named(
  self : TemplateCatalog,
  name : String,
  data : Json,
  partials : Map[String, String],
  options : RenderOptions,
) -> String raise TemplateError {
  let template = self.template(name)
  template.render_with_options_and_partials(data, partials, options)
}

///|
/// Render one named template using the catalog's own templates as partials.
/// This is convenient for catalogs where pages and partials share one manifest.
pub fn TemplateCatalog::render_self_contained(
  self : TemplateCatalog,
  name : String,
  data : Json,
  options : RenderOptions,
) -> String raise TemplateError {
  self.render_named(name, data, self.sources, options)
}

///|
/// Render a job list while retaining successful outputs and failure details.
/// A single malformed or missing job never hides the rest of the batch.
pub fn TemplateCatalog::render_jobs(
  self : TemplateCatalog,
  jobs : Array[CatalogRenderJob],
  partials : Map[String, String],
  options : RenderOptions,
) -> CatalogRenderReport {
  let outputs : Array[CatalogRenderOutput] = []
  let failures : Array[CatalogRenderFailure] = []
  let mut total_length = 0
  let mut checksum = 0
  let mut index = 0
  for job in jobs {
    try {
      let content = self.render_named(
        job.template_name,
        job.data,
        partials,
        options,
      )
      let length = content.length()
      let item_checksum = weighted_checksum(content, index + 1)
      outputs.push({
        template_name: job.template_name,
        content,
        length,
        checksum: item_checksum,
        job_index: index,
      })
      total_length += length
      checksum += item_checksum
    } catch {
      TemplateError(message) =>
        failures.push({
          template_name: job.template_name,
          message,
          job_index: index,
        })
    }
    index += 1
  }
  {
    total_jobs: jobs.length(),
    success_count: outputs.length(),
    failure_count: failures.length(),
    total_output_length: total_length,
    checksum,
    outputs,
    failures,
  }
}

///|
/// Render the same named template for a document array.
pub fn TemplateCatalog::render_many_named(
  self : TemplateCatalog,
  name : String,
  documents : Array[Json],
  partials : Map[String, String],
  options : RenderOptions,
) -> CatalogRenderReport {
  let jobs : Array[CatalogRenderJob] = []
  for document in documents {
    jobs.push(CatalogRenderJob::new(name, document))
  }
  self.render_jobs(jobs, partials, options)
}

///|
/// Render every registered name against one context. This is useful for
/// generating a page bundle or a fixed set of localized documents.
pub fn TemplateCatalog::render_all(
  self : TemplateCatalog,
  data : Json,
  options : RenderOptions,
) -> CatalogRenderReport {
  let jobs : Array[CatalogRenderJob] = []
  for name in self.names() {
    jobs.push(CatalogRenderJob::new(name, data))
  }
  self.render_jobs(jobs, self.sources, options)
}

///|
/// Return a deterministic checksum for a string. The index multiplier makes
/// the batch report sensitive to order while remaining portable across targets.
fn weighted_checksum(content : String, multiplier : Int) -> Int {
  let mut checksum = 0
  let mut index = 0
  for code_unit in content {
    checksum += code_unit.to_int() * (index + 1) * multiplier
    index += 1
  }
  checksum
}

///|
/// Return all successful output contents in job order.
pub fn CatalogRenderReport::contents(
  self : CatalogRenderReport,
) -> Array[String] {
  let result : Array[String] = []
  for output in self.outputs {
    result.push(output.content)
  }
  result
}

///|
/// Return all failed job names in job order.
pub fn CatalogRenderReport::failure_names(
  self : CatalogRenderReport,
) -> Array[String] {
  let result : Array[String] = []
  for failure in self.failures {
    result.push(failure.template_name)
  }
  result
}

///|
/// Return the first successful output, if any.
pub fn CatalogRenderReport::first_output(
  self : CatalogRenderReport,
) -> CatalogRenderOutput? {
  self.outputs.get(0)
}

///|
/// Return the first failure, if any.
pub fn CatalogRenderReport::first_failure(
  self : CatalogRenderReport,
) -> CatalogRenderFailure? {
  self.failures.get(0)
}

///|
/// Return whether all successful outputs have non-empty content.
pub fn CatalogRenderReport::all_outputs_nonempty(
  self : CatalogRenderReport,
) -> Bool {
  for output in self.outputs {
    if output.length == 0 {
      return false
    }
  }
  true
}

///|
/// Return the longest successful output length.
pub fn CatalogRenderReport::max_output_length(
  self : CatalogRenderReport,
) -> Int {
  let mut result = 0
  for output in self.outputs {
    if output.length > result {
      result = output.length
    }
  }
  result
}

///|
/// Return the shortest successful output length, or zero for an empty report.
pub fn CatalogRenderReport::min_output_length(
  self : CatalogRenderReport,
) -> Int {
  if self.outputs.length() == 0 {
    return 0
  }
  let mut result = self.outputs[0].length
  for output in self.outputs {
    if output.length < result {
      result = output.length
    }
  }
  result
}

///|
/// Return the mean successful output length using integer arithmetic.
pub fn CatalogRenderReport::average_output_length(
  self : CatalogRenderReport,
) -> Int {
  if self.success_count == 0 {
    0
  } else {
    self.total_output_length / self.success_count
  }
}

///|
/// Return whether at least one job failed.
pub fn CatalogRenderReport::has_failures(self : CatalogRenderReport) -> Bool {
  self.failure_count > 0
}

///|
/// Return all failure messages in job order.
pub fn CatalogRenderReport::failure_messages(
  self : CatalogRenderReport,
) -> Array[String] {
  let result : Array[String] = []
  for failure in self.failures {
    result.push(failure.message)
  }
  result
}

///|
/// Return successful template names in output order, including duplicates.
pub fn CatalogRenderReport::successful_template_names(
  self : CatalogRenderReport,
) -> Array[String] {
  let result : Array[String] = []
  for output in self.outputs {
    result.push(output.template_name)
  }
  result
}

///|
/// Look up an output by its original job index.
pub fn CatalogRenderReport::output_for_job(
  self : CatalogRenderReport,
  job_index : Int,
) -> CatalogRenderOutput? {
  for output in self.outputs {
    if output.job_index == job_index {
      return Some(output)
    }
  }
  None
}

///|
/// Look up a failure by its original job index.
pub fn CatalogRenderReport::failure_for_job(
  self : CatalogRenderReport,
  job_index : Int,
) -> CatalogRenderFailure? {
  for failure in self.failures {
    if failure.job_index == job_index {
      return Some(failure)
    }
  }
  None
}

///|
/// Combine reports produced by independent worker partitions. Job indices and
/// checksums remain deterministic because the right report is offset after the
/// left report's total job count.
pub fn CatalogRenderReport::merge(
  self : CatalogRenderReport,
  other : CatalogRenderReport,
) -> CatalogRenderReport {
  let outputs : Array[CatalogRenderOutput] = []
  for output in self.outputs {
    outputs.push(output)
  }
  for output in other.outputs {
    outputs.push({ ..output, job_index: output.job_index + self.total_jobs })
  }
  let failures : Array[CatalogRenderFailure] = []
  for failure in self.failures {
    failures.push(failure)
  }
  for failure in other.failures {
    failures.push({ ..failure, job_index: failure.job_index + self.total_jobs })
  }
  {
    total_jobs: self.total_jobs + other.total_jobs,
    success_count: self.success_count + other.success_count,
    failure_count: self.failure_count + other.failure_count,
    total_output_length: self.total_output_length + other.total_output_length,
    checksum: self.checksum + other.checksum,
    outputs,
    failures,
  }
}

///|
/// Render one job without requiring callers to construct a one-item array.
pub fn TemplateCatalog::render_one_job(
  self : TemplateCatalog,
  job : CatalogRenderJob,
  partials : Map[String, String],
  options : RenderOptions,
) -> CatalogRenderReport {
  self.render_jobs([job], partials, options)
}

///|
/// Render a half-open job range. This lets callers shard a large queue while
/// keeping the catalog's failure-preserving semantics.
pub fn TemplateCatalog::render_job_range(
  self : TemplateCatalog,
  jobs : Array[CatalogRenderJob],
  start : Int,
  end : Int,
  partials : Map[String, String],
  options : RenderOptions,
) -> CatalogRenderReport {
  let safe_start = if start < 0 { 0 } else { start }
  let safe_end = if end > jobs.length() { jobs.length() } else { end }
  let selected : Array[CatalogRenderJob] = []
  if safe_start < safe_end {
    for index = safe_start; index < safe_end; index = index + 1 {
      selected.push(jobs[index])
    }
  }
  self.render_jobs(selected, partials, options)
}

///|
/// Verify that a report has the expected output sequence. This is useful for
/// acceptance scripts that compare a release build with a golden fixture.
pub fn CatalogRenderReport::matches_contents(
  self : CatalogRenderReport,
  expected : Array[String],
) -> Bool {
  if self.outputs.length() != expected.length() {
    return false
  }
  for index = 0; index < expected.length(); index = index + 1 {
    if self.outputs[index].content != expected[index] {
      return false
    }
  }
  true
}

///|
/// Return a stable machine-readable summary with the main quality counters.
pub fn CatalogRenderReport::machine_summary(
  self : CatalogRenderReport,
) -> String {
  let complete = self.is_complete().to_string()
  let average = self.average_output_length()
  "jobs=\{self.total_jobs},success=\{self.success_count},failures=\{self.failure_count}," +
  "average_length=\{average},checksum=\{self.checksum},complete=\{complete}"
}
