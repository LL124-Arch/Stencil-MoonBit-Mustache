param(
  [int]$Iterations = 5
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $RepoRoot

try {
  if ($Iterations -lt 1) {
    throw "Iterations must be at least 1."
  }

  $compileAndRender = @()
  $compiledRender = @()
  $checksums = @()
  1..$Iterations | ForEach-Object {
    $lines = @(& moon run cli -- benchmark)
    if ($LASTEXITCODE -ne 0) {
      throw "moon benchmark failed on iteration $_."
    }
    $metrics = @{}
    foreach ($line in $lines) {
      if ($line -match '^([a-z_]+)=(\d+)$') {
        $metrics[$Matches[1]] = [UInt64]$Matches[2]
      }
    }
    foreach ($required in @(
        "compile_and_render_total_ms",
        "compiled_render_total_ms",
        "compile_and_render_checksum",
        "compiled_render_checksum"
      )) {
      if (-not $metrics.ContainsKey($required)) {
        throw "Missing benchmark metric '$required'."
      }
    }
    if ($metrics["compile_and_render_checksum"] -ne $metrics["compiled_render_checksum"]) {
      throw "Benchmark checksums differ on iteration $_."
    }
    $compileAndRender += $metrics["compile_and_render_total_ms"]
    $compiledRender += $metrics["compiled_render_total_ms"]
    $checksums += $metrics["compiled_render_checksum"]
  }

  $coldAverage = [math]::Round(($compileAndRender | Measure-Object -Average).Average, 2)
  $warmAverage = [math]::Round(($compiledRender | Measure-Object -Average).Average, 2)
  $checkValues = $checksums | Select-Object -Unique
  if ($checkValues.Count -ne 1) {
    throw "Benchmark output checksum was not deterministic."
  }

  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  1..$Iterations | ForEach-Object {
    & moon run cli | Out-Null
    if ($LASTEXITCODE -ne 0) {
      throw "CLI smoke run failed on iteration $_."
    }
  }
  $sw.Stop()
  $e2eTotal = [math]::Round($sw.Elapsed.TotalMilliseconds, 2)
  $e2eAverage = [math]::Round($sw.Elapsed.TotalMilliseconds / $Iterations, 2)

  Write-Host "workload: html-list-4"
  Write-Host "process_repetitions: $Iterations"
  Write-Host "engine_iterations_per_process: 200"
  Write-Host "compile_and_render_average_ms: $coldAverage"
  Write-Host "compiled_render_average_ms: $warmAverage"
  Write-Host "output_checksum: $($checkValues[0])"
  Write-Host "end_to_end_cli_total_ms: $e2eTotal"
  Write-Host "end_to_end_cli_average_ms: $e2eAverage"
  Write-Host "note: engine timings are measured inside the CLI; end-to-end timings include moon run startup and cached build overhead."
} finally {
  Pop-Location
}
