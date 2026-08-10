# Performance Baseline

Stencil records a reproducible benchmark with a real HTML-like workload. The
workload contains a title, four objects, nested variables, HTML escaping, and
repeated list rendering. Each process executes 200 iterations.

Run it from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\benchmark.ps1 -Iterations 5
```

The CLI reports two engine-level measurements:

- `compile_and_render_total_ms`: compile the template and render it on every iteration.
- `compiled_render_total_ms`: compile once, then render the compiled template repeatedly.

The wrapper also reports end-to-end `moon run` time. That number includes
process startup and cached build overhead and must not be confused with the
renderer-only measurement. Both engine modes emit a checksum; the script fails
if the two modes disagree.

## Reference run

Recorded on 2026-08-10:

| Toolchain | Host | Workload | Process repetitions | Engine iterations/process | Compile+render avg | Compiled render avg | End-to-end CLI avg |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| Moon 0.1.20260713 (`moonc v0.10.4`) | Windows 11, x64 | `html-list-4` | 5 | 200 | 6.40 ms | 1.80 ms | 99.47 ms |

Deterministic output checksum: `148600`.

This is a baseline for regression comparison on the same class of machine. It
is not a cross-machine performance guarantee. Toolchain version, CPU, process
startup, filesystem cache, and thermal state all affect the numbers.
