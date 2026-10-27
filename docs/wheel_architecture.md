# `wheel_architecture.sh`

Analyzes the contents of a wheel and predicts the appropriate compatibility layer and sub-directory of the wheelhouse where the wheel should be placed.

## Usage

```bash
Usage: wheel_architecture.sh <FILENAME>.whl
```

### Compatibility Layers and Architectures

| Layer | Architecture | Description |
| :---: | :---: | :--- |
| `generic` | `generic` | Generic across Nix and Gentoo environments, without architecture-specific CPU extensions. |
| `nix` | `generic` | Requires the Nix compatibility layer; not architecture-dependent. |
| `gentoo` | `generic` | Requires Gentoo prefix; not architecture-dependent. |
| `gentoo2020` | `generic` | Compatible with Gentoo 2020 environment. |
| `gentoo2020` | `sse3` / `avx` / `avx2` / `avx512` | Requires Gentoo 2020 and depends on libraries in the respective architecture path. |
| `gentoo2023` | `generic` | Requires Gentoo 2023; not architecture-dependent. |
| `gentoo2023` | `x86-64-v3` | Requires Gentoo 2023 and depends on libraries in `x86-64-v3`. |
| `gentoo2023` | `x86-64-v4` | Requires Gentoo 2023 and depends on libraries in `x86-64-v4`. |
| `gentoo2026` | `generic` | Requires Gentoo 2026; not architecture-dependent. |
| `gentoo2026` | `x86-64-v3` | Requires Gentoo 2026 and depends on libraries in `x86-64-v3`. |
| `gentoo2026` | `x86-64-v4` | Requires Gentoo 2026 and depends on libraries in `x86-64-v4`. |
| `unknown` | `generic` | Cannot satisfy glibc or library dependencies in standard layers, or contains local paths. |

## How It Works

1. **Extraction & Binary Inspection**: Unpacks the wheel into a temporary directory and inspects all ELF binaries and shared objects (`.so`).
2. **Local RPATH Safety Check**: Verifies that no binaries contain RPATH entries referencing user directories (`/home/` or `/.local/`). Wheels containing local RPATHs are rejected across all layers and classified as `unknown` to prevent non-portable or user-tainted builds from entering the central wheelhouse.
3. **glibc Requirement Verification**: Extracts required `GLIBC_` versions from binaries and compares them against the glibc version provided by Nix, Gentoo 2020, Gentoo 2023, and Gentoo 2026.
4. **Library Dependency Resolution**: Runs the corresponding `ldd` for each layer to detect missing shared libraries (ignoring self-contained libraries bundled inside the wheel).
5. **Architecture Detection**: Analyzes RPATH entries for CPU architecture directories (`sse3`, `avx`, `avx2`, `avx512`, `x86-64-v3`, `x86-64-v4`). Standard core paths (such as `/x86-64-v3/Core/`) are excluded so pure Python or standard runtime wheels remain generic.

!!! note
    While the script makes automated predictions, certain packages may depend on runtime libraries only present in virtual environments or specific modules. Always verify the output before deployment.

## Examples

### Pure Python wheel
```bash
$ bash wheel_architecture.sh transformers-4.49.0+computecanada-py3-none-any.whl
generic generic
```
The wheel contains no compiled extensions or shared objects.

### Architecture-specific wheel
```bash
$ bash wheel_architecture.sh pyFFTW-0.13.1+computecanada-cp311-cp311-linux_x86_64.whl
...
gentoo2023 x86-64-v3
```
This wheel depends on FFTW libraries located in the `x86-64-v3` architecture path.

### Wheel with local RPATH warning
```bash
$ bash wheel_architecture.sh custom_pkg-1.0.0+computecanada-cp311-cp311-linux_x86_64.whl
./custom_pkg/_ext.so contains a local rpath, rpath=/home/user/.local/lib:...
unknown generic
```
The wheel contains local user paths and must be rebuilt cleanly before deployment.

### Missing shared objects
Some packages link against external libraries that will be installed into a virtual environment at runtime (e.g. PyTorch):
```bash
$ bash wheel_architecture.sh torchtext-0.18.0+computecanada-cp310-cp310-linux_x86_64.whl
./torchtext/_torchtext.so requires a glibc more recent than that provided by Gentoo 2020: 2.34 > 2.30
	libtorch_python.so => not found
	libc10.so => not found
	libtorch.so => not found
unknown generic
```
Since `libtorch.so` is missing during inspection, `wheel_architecture.sh` reports `unknown`. If you know the package targets Gentoo 2023/2026, deploy it explicitly with `cp_wheels.sh --arch generic`.
