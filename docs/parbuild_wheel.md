# `parbuild_wheel.sh`

Builds multiple versions and/or multiple Python wheels in parallel using GNU `parallel`.
The script utilizes available CPU cores to execute separate `build_wheel.sh` instances concurrently.

## Usage

```bash
Usage: parbuild_wheel.sh 
  --package <comma-separated list of package names>
  [--version <comma-separated list of versions>]
  [--python <comma-separated list of python versions>]
  [--requirements <requirements file>]
```

### Options

| Option | Description |
| :--- | :--- |
| `--package <names>` | Comma-separated list of packages to build (**required** unless `--requirements` is specified). |
| `--version <versions>` | Comma-separated list of package versions. If omitted, builds the latest version. |
| `--python <versions>` | Comma-separated list of Python versions. Defaults to all active Python versions in the current StdEnv. |
| `--requirements <file>` | Path to a requirements file specifying packages and optional versions to build. |

## Standard Environment & Behavior

- **StdEnv 2026 (`2026`)**: Excludes Python versions $\le$ 3.13, targeting Python 3.14+.
- **StdEnv 2023 (`2023`)**: Excludes Python versions $\le$ 3.10, targeting Python 3.11 to 3.14.
- **Non-recursive Builds**: Underlying invocations call `build_wheel.sh` with `--recursive 0` and `--verbose 3` so that concurrent jobs do not build duplicate dependencies.

## Requirements File Syntax

When passing `--requirements <file>`, `parbuild_wheel.sh` processes:
- **Pinned packages** (`package==version`): Builds the specified version across all selected Python versions.
- **Unpinned packages** (`package`): Builds the latest PyPI version across all selected Python versions.
- Trailing semicolons (often found in freeze files) are automatically stripped. Other complex constraint specifiers (such as `>=`, `<`, or environment markers) should be adapted to `==` or unpinned lines.

## Output Logs & Process Control

- **Individual Build Logs**: Written to `build-{package}-{version}-py{python}.log` (or `build-{package}-py{python}.log` for unpinned builds) in the current directory.
- **Commands List**: Commands to be run are generated into `<PID>.cmds`.
- **Parallel Job Log**: Execution status for all jobs is recorded in `<PID>.log` and summarized upon completion.
- **Cancelling Jobs**: Press `Ctrl+C` in the terminal, or terminate running parallel tasks with:
  ```bash
  $ killall -TERM parallel
  ```

## Examples

### Build package across all default Python versions
```bash
$ bash parbuild_wheel.sh --package biopython
```

### Build multiple packages in parallel
```bash
$ bash parbuild_wheel.sh --package numpy,scipy,pandas
```

### Build multiple versions of a package
```bash
$ bash parbuild_wheel.sh --package biopython --version 1.83,1.84
```

### Build specific Python versions
```bash
$ bash parbuild_wheel.sh --package biopython --python 3.11,3.12
```

### Batch build from a requirements file
```bash
$ bash parbuild_wheel.sh --requirements requirements.txt
```
