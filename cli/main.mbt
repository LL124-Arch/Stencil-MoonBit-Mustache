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
  let workload = @lib.production_benchmark_workload()
  let result = @lib.run_benchmark(workload)
  println("benchmark=stencil")
  println("workload=" + result.workload)
  println("iterations=" + result.iterations.to_string())
  println("output_length=" + result.output_length.to_string())
  println("checksum=" + result.checksum.to_string())
  println(@lib.benchmark_summary(result))
  println("consistent=" + @lib.benchmark_is_consistent(result).to_string())
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
fn wants_command(args : Array[String], command : String) -> Bool {
  for arg in args {
    if arg == command {
      return true
    }
  }
  false
}

///|
fn analyze_demo() -> Unit {
  let source = "<!doctype html>\n<h1>{{title}}</h1>\n{{#items}}{{>card}}{{/items}}"
  try {
    let stats = @lib.analyze(source)
    println("analysis=" + stats.summary())
    println("complexity_score=" + stats.complexity_score().to_string())
  } catch {
    @lib.TemplateError(message) => println("Analysis error: \{message}")
  }
}

///|
fn compatibility_demo() -> Unit {
  let results = @lib.run_compatibility_suite(@lib.compatibility_cases())
  println("compatibility=" + @lib.compatibility_summary(results))
  for failure in @lib.compatibility_failures(results) {
    println(
      "failure=" +
      failure.name +
      ": expected=" +
      failure.expected +
      ", actual=" +
      failure.actual,
    )
  }
}

///|
fn main {
  let args = @env.args()
  if wants_benchmark(args) {
    benchmark() catch {
      @lib.TemplateError(msg) => println("Benchmark error: \{msg}")
    }
  } else if wants_command(args, "analyze") {
    analyze_demo()
  } else if wants_command(args, "compatibility") {
    compatibility_demo()
  } else {
    demo()
  }
}
