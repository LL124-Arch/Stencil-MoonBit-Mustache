param(
  [string]$CutoffDate = "2026-04-29"
)

$ErrorActionPreference = "Stop"

function Write-Section {
  param([string]$Title)
  Write-Host ""
  Write-Host "== $Title =="
}

function Assert-File {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Missing required path: $Path"
  }
  Write-Host "ok  $Path"
}

function Invoke-Step {
  param(
    [string]$Label,
    [scriptblock]$Action
  )
  Write-Host "-- $Label"
  & $Action
  if ($LASTEXITCODE -ne 0) {
    throw "Step failed: $Label"
  }
}

function Get-DefaultBranch {
  param([string]$RemoteName)
  $raw = git ls-remote --symref $RemoteName HEAD 2>$null
  if (-not $raw) {
    return $null
  }
  foreach ($line in $raw) {
    if ($line -match '^ref:\s+refs/heads/([^\s]+)\s+HEAD$') {
      return $Matches[1]
    }
  }
  return $null
}

function Get-GitLinkRemoteName {
  $remotes = git remote
  foreach ($remote in $remotes) {
    $url = git remote get-url $remote 2>$null
    if ($url -match 'gitlink\.org\.cn') {
      return $remote
    }
  }
  return $null
}

function Test-CompilerAvailable {
  foreach ($name in @("cl", "cc", "gcc", "clang")) {
    if (Get-Command $name -ErrorAction SilentlyContinue) {
      return $true
    }
  }
  return $false
}

function Assert-NoGeneratedInterfaceDiff {
  foreach ($path in @("src/pkg.generated.mbti", "cli/pkg.generated.mbti")) {
    git diff --quiet -- $path
    if ($LASTEXITCODE -ne 0) {
      throw "Generated interface file is not up to date: $path"
    }
  }
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $RepoRoot

try {
  Write-Section "Required Files"
  @(
    "README.md",
    "LICENSE",
    "moon.mod",
    ".github/workflows/ci.yml",
    ".gitlink/workflows/ci.yml",
    "src",
    "cli",
    "docs/acceptance-checklist.md"
  ) | ForEach-Object { Assert-File $_ }

  Write-Section "Repository Metadata"
  $commitCount = git rev-list --count HEAD
  $postCutoffCount = git rev-list --count --since="${CutoffDate}T00:00:00+08:00" HEAD
  $originDefault = Get-DefaultBranch "origin"
  $gitlinkRemote = Get-GitLinkRemoteName
  $gitlinkDefault = if ($gitlinkRemote) { Get-DefaultBranch $gitlinkRemote } else { $null }

  Write-Host "total commits: $commitCount"
  Write-Host "commits since ${CutoffDate}: $postCutoffCount"
  Write-Host "origin default branch: $originDefault"
  if ($gitlinkRemote) {
    Write-Host "$gitlinkRemote default branch: $gitlinkDefault"
  } else {
    Write-Host "gitlink remote: not configured locally"
  }

  Write-Section "MoonBit Source Scale"
  $sourceFiles = Get-ChildItem -Recurse -File -Include *.mbt -Path "src", "cli"
  $sourceLines = 0
  foreach ($file in $sourceFiles) {
    $sourceLines += (Get-Content -LiteralPath $file.FullName).Count
  }
  Write-Host "MoonBit source files: $($sourceFiles.Count)"
  Write-Host "MoonBit source lines: $sourceLines"

  Write-Section "Toolchain"
  moon version --all

  Write-Section "Verification"
  Invoke-Step "moon fmt --check" { moon fmt --check }
  Invoke-Step "moon check --deny-warn --target all" { moon check --deny-warn --target all }
  Invoke-Step "moon build --target wasm,wasm-gc,js" { moon build --target wasm,wasm-gc,js }
  Invoke-Step "moon info --target all" { moon info --target all }
  Invoke-Step "generated interfaces clean" { Assert-NoGeneratedInterfaceDiff }
  Invoke-Step "moon test --deny-warn --target wasm,wasm-gc,js" {
    moon test --deny-warn --target wasm,wasm-gc,js
  }
  if (Test-CompilerAvailable) {
    Invoke-Step "moon build --target native" {
      moon build --target native
    }
    Invoke-Step "moon test --deny-warn --target native" {
      moon test --deny-warn --target native
    }
  } else {
    Write-Host "-- skipping native test: no system C compiler found"
  }

  Write-Section "Acceptance Summary"
  Write-Host "Repository baseline checks completed successfully."
} finally {
  Pop-Location
}
