# Performance Baseline

Stencil records a reproducible benchmark with a real HTML-like workload. The
workload contains a title, four objects, nested variables, HTML escaping, and
repeated list rendering. Each process executes 200 iterations.

Run it from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\benchmark.ps1 -Iterations 5
```

The CLI reports a reusable workload result and the PowerShell wrapper records
end-to-end process timing:

- `workload=catalog-page-4-items`: four realistic catalog items with nested fields.
- `iterations=200`, `output_length`, and `checksum`: deterministic correctness evidence.
- `consistent=true`: verifies every compiled render has the same output length.

The wrapper also reports end-to-end `moon run` time. That number includes
process startup and cached build overhead and must not be confused with the
renderer-only measurement. Both engine modes emit a checksum; the script fails
if the two modes disagree.

## Reference run

Recorded on 2026-08-15:

| Toolchain | Host | Workload | Process repetitions | Engine iterations/process | Compile+render avg | Compiled render avg | End-to-end CLI avg |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| Moon 0.1.20260703 (`moonc v0.10.3`) | Windows 11, x64 | `catalog-page-4-items` | 1 | 200 | see CLI output | see CLI output | measured by wrapper |

Reference CLI output checksum: `13205700`; output length: `657`.

This is a baseline for regression comparison on the same class of machine. It
is not a cross-machine performance guarantee. Toolchain version, CPU, process
startup, filesystem cache, and thermal state all affect the numbers.
