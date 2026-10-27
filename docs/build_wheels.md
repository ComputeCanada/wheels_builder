# `build_wheel.sh`

Build wheel(s) for a Python package.

This script will:

- Create a build-virtualenv based on the Python version and install any dependencies.
- Download the package from PyPI (by default), either the version specified or else the latest.
- Build the wheel.
- Add the `+computecanada` local version tag to the wheel name.
- Automatically inspect and adjust NumPy and PyTorch requirements if shared libraries link against them.
- Install the wheel into the build-virtualenv and try to import it.

## Usage

```bash
Usage: build_wheel.sh --package <python package name>
         [--version <specific version>]
         [--python <comma separated list of python versions>]
         [--recursive=<1|0>]
         [--keep-build-dir]
         [--autocopy]
         [--no-verify]
         [--verbose=<1,2,3>]
         [--job]
         [--dependency=<dependency>]
         [--cpus|--job-cores=<number of cpus>]
         [--mem-cpu=<memory per cpu>[mM|gG]]
```

### Options

| Option | Description | Default |
| :--- | :--- | :--- |
| `--package <name>` | Python package name to build (**required**). | |
| `--version <version>` | Specific version to build. If omitted, downloads latest from PyPI. | Latest |
| `--python <versions>` | Comma-separated list of Python versions to build for (e.g. `3.11,3.12`). | Available versions in current StdEnv |
| `--recursive <1\|0>` | Whether to recursively build downloaded dependencies. | `1` (enabled) |
| `--keep-build-dir` | Retain the temporary build directory (`/tmp/build_wheels_tmp.$$`) instead of deleting it. | `0` (disabled) |
| `--autocopy` | Automatically call `cp_wheels.sh --remove` upon successful build. | `0` (disabled) |
| `--no-verify` | Skip checking source files for `-march=native` or `-xHost` flags. | `0` (verification active) |
| `--verbose <1,2,3>` | Verbosity level for commands and logs (`1`: commands, `2`: commands + output on failure, `3`: full stream). | `0` |
| `--job` | Submit the build command as a Slurm batch job using `sbatch`. | `0` (runs locally) |
| `--dependency <dep>` | Slurm job dependency specification passed to `sbatch` (e.g. `afterok:<jobid>`). | None |
| `--cpus` / `--job-cores <N>` | Number of CPU cores requested for the Slurm job. | `1` |
| `--mem-cpu <size>` | Memory per CPU requested for the Slurm job (e.g. `3G`, `8000M`). | `3G` |

## Standard Environment & Architecture

By default, `build_wheel.sh` adapts its compiler and module environment to the currently loaded Standard Environment (`EBVERSIONGENTOO`):

- **StdEnv 2026 (`2026`)**: Uses GCC 15.3, Cython 3.3.0, NumPy 2.5.3, Rust, and builds for Python 3.14+ (excludes $\le$ 3.13).
- **StdEnv 2023 (`2023`)**: Uses GCC 12.3, Cython 3.2.4, NumPy 2.4.2, Rust, and builds for Python 3.11 to 3.14 (excludes $\le$ 3.10).

To build architecture-optimized wheels:
- In **StdEnv 2023 and 2026**: load `module load arch/avx2` (maps to `x86-64-v3`) or `module load arch/avx512` (maps to `x86-64-v4`).

When `-march=native` is encountered in package sources, `build_wheel.sh` automatically rewrites it to target the active architecture (`x86-64-v3` / `x86-64-v4` in 2023+ or `core-avx2` / `skylake-avx512` in 2020), unless `--no-verify` is given.

## Automatic Requirement Adjustment & Tagging

1. **NumPy**: If compiled extensions contain references to NumPy C API, `build_wheel.sh` inspects the build version:
   - For NumPy 1.x builds, it pins the minimum required NumPy version and adds `<2.0`.
   - For NumPy 2.x builds, minimum version pinning is skipped.
2. **PyTorch**: If compiled extensions link against `libtorch.so` (or if `TORCH_VERSION` is specified in configuration), `build_wheel.sh`:
   - Pins a compatible PyTorch version (`torch (~=X.Y.0)`).
   - If a wheel with the same version already exists in the central wheelhouse, it tags the new wheel with `+torchXY.computecanada` to avoid collisions.
3. **Pure Python & ABI3 wheels**:
   - If the built wheel is pure Python (`py3-none-any`, `py2.py3-none-any`) or ABI3 compatible (`cp*-abi3`), `build_wheel.sh` finishes after the first Python version since the artifact is compatible with all versions.

## Configuration Files

`build_wheel.sh` assumes standard package and module naming, but packages needing customization can define a configuration file in `config/`:
1. `config/${PACKAGE}-${VERSION}.sh`
2. `config/${PACKAGE}.sh`

See the [Configuration Guide](config.md) for available variables and hooks.

## Examples

### Build latest version
Builds the latest version from PyPI for all default Python versions in the current environment:
```bash
$ bash build_wheel.sh --package biopython
```

### Build specific package version
```bash
$ bash build_wheel.sh --package biopython --version 1.84 --verbose 3
```

### Build specific Python version
```bash
$ bash build_wheel.sh --package biopython --python 3.14 --verbose 3
```

### Disable recursive dependency builds
```bash
$ bash build_wheel.sh --package biopython --recursive 0
```

### Keep build directory for debugging
Preserves the temporary build directory under `/tmp` to inspect build logs or patched source files:
```bash
$ bash build_wheel.sh --package biopython --version 1.84 --keep-build-dir
```

### Automatically copy upon success
```bash
$ bash build_wheel.sh --package biopython --autocopy
```

### Submit a build job with Slurm
```bash
$ bash build_wheel.sh --package biopython --version 1.84 --verbose 3 --job --cpus 4 --mem-cpu 8G
Submitted batch job 4680
```
This creates a batch job output log (`biopython-1.84-<jobid>.log`) in the current directory.

### Submit a chained dependent job
Submit a build job that starts only after another job finishes successfully:
```bash
$ bash build_wheel.sh --package scipy --job --dependency afterok:4680
```
