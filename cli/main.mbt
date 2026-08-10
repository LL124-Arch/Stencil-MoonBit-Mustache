///|
fn demo() -> Unit {
  let template = "Hello {{name}}! Welcome to {{project}}."
  let data : Json = {
    "name": "developer",
    "project": "Stencil Template Engine",
  }
  try {
    let result = @lib.render(template, data)
    println(result)
  } catch {
    @lib.TemplateError(msg) => println("Error: \{msg}")
  }
}

///|
fn benchmark() -> Unit raise @lib.TemplateError {
  let template = "<!doctype html>\n" +
    "<h1>{{title}}</h1>\n" +
    "{{#items}}<article><h2>{{name}}</h2>" +
    "<p>{{description}}</p><a href=\"{{url}}\">{{url}}</a></article>\n" +
    "{{/items}}{{^items}}empty{{/items}}"
  let data : Json = {
    "title": "Stencil benchmark",
    "items": [
      {
        "name": "MoonBit",
        "description": "A statically typed language for portable systems.",
        "url": "https://www.moonbitlang.com/",
      },
      {
        "name": "WASM",
        "description": "A compact target for edge and serverless workloads.",
        "url": "https://webassembly.org/",
      },
      {
        "name": "Mustache",
        "description": "Logic-less templates with safe interpolation.",
        "url": "https://mustache.github.io/",
      },
      {
        "name": "Stencil",
        "description": "A MoonBit-native implementation with no runtime dependency.",
        "url": "https://github.com/LL124-Arch/Stencil-MoonBit-Mustache",
      },
    ],
  }
  let iterations = 200
  let mut cold_checksum = 0
  let cold_start = @env.now()
  for i = 0; i < iterations; i = i + 1 {
    let output = @lib.render(template, data)
    cold_checksum = cold_checksum + output.length()
  }
  let cold_elapsed = @env.now() - cold_start

  let compiled = @lib.compile(template)
  let mut warm_checksum = 0
  let warm_start = @env.now()
  for i = 0; i < iterations; i = i + 1 {
    let output = compiled.render(data)
    warm_checksum = warm_checksum + output.length()
  }
  let warm_elapsed = @env.now() - warm_start

  println("benchmark=stencil")
  println("workload=html-list-4")
  println("iterations=" + iterations.to_string())
  println("compile_and_render_total_ms=" + cold_elapsed.to_string())
  println("compiled_render_total_ms=" + warm_elapsed.to_string())
  println("compile_and_render_checksum=" + cold_checksum.to_string())
  println("compiled_render_checksum=" + warm_checksum.to_string())
}

///|
fn wants_benchmark(args : Array[String]) -> Bool {
  let mut i = 0
  while i < args.length() {
    if args[i] == "benchmark" {
      return true
    }
    i = i + 1
  }
  false
}

///|
fn main {
  let args = @env.args()
  if wants_benchmark(args) {
    benchmark() catch {
      @lib.TemplateError(msg) => println("Benchmark error: \{msg}")
    }
  } else {
    demo()
  }
}
