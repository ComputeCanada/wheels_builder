# `cp_wheels.sh`

Copies all wheels in the current directory to the predicted location in the wheelhouse
after adjusting file permissions (`chmod ug+rw,o+r`).

## Usage

```bash
Usage: cp_wheels.sh [--wheel <wheel file>] [--arch generic|<rsnt_arch>]
                    [--remove] [--dry-run] [--force]
```

### Options

| Option | Description |
| :--- | :--- |
| `--wheel <wheel file>` | Process only this specific wheel file (otherwise processes all `*computecanada*.whl` files in the current working directory). |
| `--arch generic\|<rsnt_arch>` | Copy to a generic or architecture-specific directory. |
| `--remove` | Delete the local wheel file after successful copy. |
| `--dry-run` | Print copy and removal commands without executing them. |
| `--force` | Overwrite existing wheels in the wheelhouse (uses `cp -v`). By default, `cp_wheels.sh` prevents overwriting existing wheels with `cp -vn` (no-clobber). |

## Architecture & Compatibility Rules

If `cp_wheels.sh` detects an architecture-specific wheel, it refuses to copy it as generic unless the `--arch` flag is provided. The script considers a wheel to be architecture-specific if:
1. It links external libraries outside the standard compatibility layer, or
2. Existing wheels for the same package are already located in arch-specific directories in the wheelhouse.

### Valid Architectures by Standard Environment

- **StdEnv 2023 and 2026 (`EBVERSIONGENTOO >= 2023`)**:
  - `generic`
  - `x86-64-v3`
  - `x86-64-v4`
  Generic wheels built under StdEnv 2026 are routed to `gentoo2026`, and wheels built under StdEnv 2023 are routed to `gentoo2023`.
- **StdEnv 2020 (`EBVERSIONGENTOO == 2020`)**:
  - `generic`
  - `sse3`
  - `avx`
  - `avx2`
  - `avx512`

If an unknown compatibility layer is detected, run `bash wheel_architecture.sh <wheel>` to inspect the linkage and compatibility issues.

## Examples

### Copy all wheels and remove local copies
Processes all `*computecanada*.whl` files in the current directory:
```bash
$ bash cp_wheels.sh --remove
```

### Dry run
Inspect the predicted destination and actions without copying or deleting files:
```bash
$ bash cp_wheels.sh --dry-run
```

### Copy specific wheel
```bash
$ bash cp_wheels.sh --remove --wheel fastrlock-0.8.3+computecanada-cp313-cp313-linux_x86_64.whl
```

### Copy to specific architecture
```bash
$ bash cp_wheels.sh --remove --arch x86-64-v3 --wheel <name>
```

### Force overwrite existing wheel in the wheelhouse
```bash
$ bash cp_wheels.sh --force --wheel numpy-2.2.0+computecanada-cp312-cp312-linux_x86_64.whl
```

### Copy multiple matched wheels with GNU Parallel
```bash
$ parallel bash cp_wheels.sh --remove --wheel ::: alphafold3-3.0.1+computecanada-cp31* numpy-*.whl
```
