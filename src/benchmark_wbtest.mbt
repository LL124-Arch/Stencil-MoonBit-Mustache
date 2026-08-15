///|
test "production benchmark workload is stable" {
  let workload = production_benchmark_workload()
  assert_eq(workload.name, "catalog-page-4-items")
  assert_eq(workload.iterations, 200)
  let result = run_benchmark(workload)
  assert_eq(benchmark_is_consistent(result), true)
  assert_eq(result.total_output_length, result.output_length * 200)
  assert_eq(result.checksum > result.total_output_length, true)
}

///|
test "benchmark summary is machine-readable" {
  let result = run_benchmark(production_benchmark_workload())
  let summary = benchmark_summary(result)
  assert_eq(summary.contains("workload=catalog-page-4-items"), true)
  assert_eq(summary.contains("iterations=200"), true)
  assert_eq(summary.contains("checksum="), true)
}
