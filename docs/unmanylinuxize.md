# `unmanylinuxize.sh`

Downloads a pre-built `manylinux` wheel from PyPI, an external wheel index, or a direct URL, and patches its RPATH and metadata to make it compatible with the DRAC software stack.

!!! tip "Build from source when possible"
    Prefer building from source using `build_wheel.sh` when possible to benefit from optimization and consistent library linkage.

Packages distributed as binary wheels often carry `manylinux` tags in their filenames. Out of the box, these wheels are typically incompatible with our software stack because libraries reside in custom CVMFS paths rather than standard system directories.

`unmanylinuxize.sh` downloads the wheel, patches RPATHs using `setrpaths`, applies optional package-specific patch commands, renames the `manylinux` platform tag to `linux_x86_64`, and appends the `+computecanada` local version tag.

## Usage

```bash
Usage: unmanylinuxize.sh 
  --package <package name> 
  [--version <version>]
  [--python <comma separated list of python versions>]
  [--add_path <rpath>]
  [--add_origin]
  [--find_links https://index.url | --url https://direct.url.to.wheel.whl]
```

### Options

| Option | Description |
| :--- | :--- |
| `--package <name>` | Python package name (**required** unless `--url` is specified). |
| `--version <version>` | Package version to download (defaults to latest if omitted). |
| `--python <versions>` | Comma-separated list of Python versions to download for. Defaults to all active Python versions in the current StdEnv. |
| `--add_path <rpath>` | Additional directory path(s) to append to the RPATH using `setrpaths --add_path <rpath> --any_interpreter`. |
| `--add_origin` | Flag to add `$ORIGIN` to the RPATH via `setrpaths --add_origin`. |
| `--find_links <url>` | Custom index URL to search for wheels (sets `PIP_FIND_LINKS`). |
| `--url <url>` | Direct URL to download a specific `.whl` file using `wget`. |

## Standard Environment & Behavior

- **StdEnv 2026 (`2026`)**: Excludes Python versions <=3.13, downloading for Python 3.14+.
- **StdEnv 2023 (`2023`)**: Excludes Python versions <=3.10, downloading for Python 3.11, 3.12, and 3.13.
- **Pure Python & ABI3 Early Exit**: If a downloaded wheel is `py3-none-any`, `py2.py3-none-any`, or ABI3 compatible (`cp*-abi3`), downloading terminates after the first Python version since the artifact is compatible across all versions.
- **Configuration Recipes**: Sources configuration recipes from `config/` (`config/<package>-<version>.sh` or `config/<package>.sh`), executing any defined `PATCH_WHEEL_COMMANDS`.

## Examples

### Download and patch specific version
```bash
$ bash unmanylinuxize.sh --package sktime --version 0.21.1
```

### Specific Python version
```bash
$ bash unmanylinuxize.sh --package sktime --version 0.21.1 --python 3.11
```

### Add specific library RPATH
Preload required modules and add library directories to RPATH:
```bash
$ module load cuda/12 cudnn/9
$ bash unmanylinuxize.sh --package open3d --add_path $EBROOTCUDACORE/lib/:$EBROOTCUDNN/lib
```

### Add `$ORIGIN` to RPATH
Useful for wheels that bundle shared libraries in internal directories and locate them relative to `$ORIGIN`:
```bash
$ bash unmanylinuxize.sh --package mypkg --version 1.0.0 --add_origin
```

### Download from alternative index
```bash
$ bash unmanylinuxize.sh --package cupy-cuda12x --find_links https://pypi.nvidia.com
```

### Download from direct URL
```bash
$ bash unmanylinuxize.sh --url https://github.com/example/pkg/releases/download/v1.0.0/pkg-1.0.0-cp311-cp311-manylinux2014_x86_64.whl
```
