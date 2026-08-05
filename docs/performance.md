# Performance Baseline

This repository records a reproducible end-to-end smoke benchmark for the CLI
example. It is intentionally not presented as a renderer-only throughput
claim: each sample includes `moon run` startup and cached build overhead.

Run it from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\benchmark.ps1 -Iterations 20
```

Reference run on 2026-08-06:

| Toolchain | Host | Workload | Total | Average |
| --- | --- | --- | ---: | ---: |
| Moon 0.1.20260713 (`moonc v0.10.4`) | Windows 11, x64 | 5 CLI runs | 489.24 ms | 97.85 ms/run |

Use the script again on the target runner before comparing numbers. Changes in
the MoonBit toolchain, filesystem cache, or host CPU can materially affect this
smoke measurement.
