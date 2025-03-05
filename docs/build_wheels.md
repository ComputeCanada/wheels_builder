# `build_wheels.sh`

Build wheel(s) for a Python package.

This script will:
- Create a build-virtualenv based on the Python version and install any dependencies.
- Download the package from PyPI (by default), either the version specified or else the latest.
- Build the wheel.
- Add the `+computecanada` to the wheel name.
- install the wheel into the build-virtualenv and try to import it.

By default,
- it tries to build wheels for Python 3.11 to 3.13;
- all downloaded dependencies will be built.

To build AVX512-optimized wheels, do `module load arch/avx512` before calling `build_wheel.sh`. This has no effect on generic packages, i.e.
those that do not contain compiled libraries and do not link external ones.

`build_wheel.sh` assumes that the package name is also the first part of the 
downloaded archive, the directory name of the extracted archive and the name
of the module when imported, however for importing it also try some variants by 
trying some prefixes or suffixes (python, py, Py, 2).

While these assumptions work surprisingly well, many packages need special treatment,
by creating a [`package.sh` file in the `config/` directory](https://github.com/ComputeCanada/wheels_builder/wiki/Configuration),
which will be sourced and can therefore be used to configure the build.
In these variations of the package-, archive-, folder-, import-name can be specified
as well as differing download-, build-, and test-commands.
See the [variable section](https://github.com/ComputeCanada/wheels_builder/wiki/Configuration#variables) for a list of options.

## Examples
### Build latest
Builds the latest version from PyPI:
```bash
$ bash build_wheel.sh --package biopython
```

### Build specific version
Builds the version `1.84` from PyPI for the default python versions (3.11, 3.12, 3.13):
```bash
$ bash build_wheel.sh --package biopython --version 1.84 --verbose 3
```

### Build specific python version
Builds the latest version from PyPI with Python 3.13. Builds dependencies recursively for Python 3.13 as well.
```bash
$ bash build_wheel.sh --package biopython --python 3.13 --verbose 3
```

### Disable recursive builds
By default, all downloaded dependencies will be built. This can be disabled with:
```bash
$ bash build_wheel.sh --package biopython --recursive 0
```

### Submit a build job
Your time matters, a build job can be submitted with:
```bash
$ bash build_wheel.sh --package biopython --verbose 3 --job
Submitted batch job 4680
```
By default, the job uses `1` cpu and `3Gb` of memory.
A log file containing the job output (`biopython-4680.log`) will be created in the current directory.

#### Specifying resources
One can request more resources with:
```bash
$ bash build_wheel.sh --package biopython --verbose 3 --job --job-cores 4 --mem-cpu 8G
```