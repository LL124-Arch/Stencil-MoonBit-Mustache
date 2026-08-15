/// Benchmark workload definitions shared by CLI and tests.

///|
pub(all) struct BenchmarkWorkload {
  name : String
  template : String
  data : Json
  iterations : Int
} derive(Debug)

///|
pub(all) struct BenchmarkResult {
  workload : String
  iterations : Int
  output_length : Int
  total_output_length : Int
  checksum : Int
} derive(Debug)

///|
pub fn production_benchmark_workload() -> BenchmarkWorkload {
  {
    name: "catalog-page-4-items",
    template: "<!doctype html>\n<h1>{{title}}</h1>\n{{#items}}<article><h2>{{name}}</h2><p>{{description}}</p><a href=\"{{url}}\">{{url}}</a></article>\n{{/items}}{{^items}}empty{{/items}}",
    data: {
      "title": "Stencil benchmark",
      "items": [
        {
          "name": "MoonBit",
          "description": "A statically typed language.",
          "url": "https://www.moonbitlang.com/",
        },
        {
          "name": "WASM",
          "description": "A portable compilation target.",
          "url": "https://webassembly.org/",
        },
        {
          "name": "Mustache",
          "description": "A logic-less template model.",
          "url": "https://mustache.github.io/",
        },
        {
          "name": "Stencil",
          "description": "A MoonBit-native implementation.",
          "url": "https://github.com/LL124-Arch/Stencil-MoonBit-Mustache",
        },
      ],
    },
    iterations: 200,
  }
}

///|
pub fn run_benchmark(
  workload : BenchmarkWorkload,
) -> BenchmarkResult raise TemplateError {
  let template = compile(workload.template)
  let output = template.render(workload.data)
  let mut total = 0
  let mut checksum = 0
  for i = 0; i < workload.iterations; i = i + 1 {
    let rendered = template.render(workload.data)
    total += rendered.length()
    checksum += rendered.length() * (i + 1)
  }
  {
    workload: workload.name,
    iterations: workload.iterations,
    output_length: output.length(),
    total_output_length: total,
    checksum,
  }
}

///|
pub fn benchmark_is_consistent(result : BenchmarkResult) -> Bool {
  result.output_length > 0 &&
  result.total_output_length == result.output_length * result.iterations
}

///|
pub fn benchmark_summary(result : BenchmarkResult) -> String {
  "workload=\{result.workload}, iterations=\{result.iterations}, output_length=\{result.output_length}, checksum=\{result.checksum}"
}
