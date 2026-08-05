param(
  [int]$Iterations = 20
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $RepoRoot

try {
  if ($Iterations -lt 1) {
    throw "Iterations must be at least 1."
  }

  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  1..$Iterations | ForEach-Object {
    & moon run cli | Out-Null
    if ($LASTEXITCODE -ne 0) {
      throw "moon run cli failed on iteration $_."
    }
  }
  $sw.Stop()

  $total = [math]::Round($sw.Elapsed.TotalMilliseconds, 2)
  $perRun = [math]::Round($sw.Elapsed.TotalMilliseconds / $Iterations, 2)
  Write-Host "iterations: $Iterations"
  Write-Host "total_ms: $total"
  Write-Host "average_ms_per_cli_run: $perRun"
  Write-Host "note: this is an end-to-end CLI smoke benchmark and includes moon run startup overhead."
} finally {
  Pop-Location
}
