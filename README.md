# ComputeCanada/wheels\_builder

Scripts to automate building Python wheels for Compute Canada's wheelhouse.

**Table of Content:**

* [Quick Start](#quick-start)
  * [`build_wheel.sh`](#build_wheelsh)
  * [`wheel_architecture.sh`](#wheel_architecturesh)
  * [`cp_wheels.sh`](#cp_wheelssh)
  * [`parbuild_wheel.sh`](#parbuild_wheelsh)
  * [`protobuf_optimized_wheel.sh`](#protobuf_optimized_wheelsh)
  * [`unmanylinuxize.sh`](#unmanylinuxizesh)
  * [`config/<package>.sh`](#configpackagesh)
  * [`manipulate_wheels.py`](#manipulate_wheelspy)


## Quick Start

### `build_wheel.sh`

Build wheel(s) for a Python package.

```
Usage: build_wheel.sh --package <python package name> 
         [--version <specific version]
         [--recursive=<1|0>]
         [--python=<comma separated list of python versions>]
         [--keep-build-dir]
         [--verbose=<1,2,3>]

    --recursive       Recursively build wheels for dependencies.
    --package         Name of the Python package to build.
    --version         Version of the Python package to build. (default:  latest)
    --python          Build wheels for these Python versions. (default: "3.8,3.9,3.10,3.11")
    --keep-build-dir  Don't delete build-dirs after successful build.
    --autocopy        Run `./cp_wheels.sh --remove` after successful build.
    --verbose         Set level for verbosity. (0,1,2,3; default: 0)
 -h --help            Print help message.

```

This script will:
- Create a build-virtualenv based on the (first) Python version and install dependencies.
- Download the package from PyPI (by default), either the version specified or else the latest.
- Build the wheel.
- To test: install the wheel into the build-virtualenv and try to import it.

By default, it tries to build wheels for Python 3.8, 3.9, 3.10, and 3.11.

If no `arch` module is loaded, it will load `arch/sse3`, our current smallest
common denominator. To build AVX2-optimised wheels, do `module load arch/avx2`
before calling `build_wheel.sh`. This has no effect on generic packages, i.e.
those that do not contain compiled libraries and do not link external ones.

`build_wheel.sh` assumes that the package name is also the first part of the 
downloaded archive, the directory name of the extracted archive and the name
of the module when imported, however for importing also try some variants by 
trying some prefixes or suffixes (python, py, Py, 2).

While these assumptions work surprisingly well, many packages need special treatment,
by creating a [`package.sh` file in the `config/` directory](#configpackagesh),
which will be sourced and can therefore be used to configure the build.
In there variations of the package-, archive-, folder-, import-name can be specified
as well as differing download-, build-, and test-commands.
See [below](#configpackagesh) for a list of options.

-------------------------------------------------------------------------------
### `wheel_architecture.sh`

Analyzes the content of the wheel and makes some prediction into which sub-directory
of our wheelhouse the wheel needs to be placed.

```
Usage: wheel_architecture.sh  <FILENAME>.whl
```

* generic generic : Generic in terms of nix/gentoo prefix as well as for architecture
* nix     generic : requires NIX but is not architecture dependent
* gentoo  generic : requires Gentoo prefix but is not architecture dependent
* nix     avx2    : requires NIX and depends on libraries located in arch/avx2
* ...

*NOTE*: While the script tries to make a good job, there are cases e.g. when a wheel
depends on a certain library or certain version of a library that is available only 
in one of the NIX or Gentoo layers but not the other, where it makes a wrong prediction.

Make sure to test it!

-------------------------------------------------------------------------------
### `cp_wheels.sh`

Copies all wheels in the current directory to the predicted location in the wheelhouse
after adjusting the permissions. 

```
Usage: cp_wheels.sh [--wheel <wheel file>] [--arch generic|<rsnt_arch>]
                    [--remove] [--dry-run]

   --wheel <wheel file>       Process only this wheel (otherwise all in the $CWD)
   --arch generic|<rsnt_arch> Copy to a generic or arch-specific directory.
   --remove                   Delete the wheel after copying.
   --dry-run                  Just print the commands, but don't execute anything.
```

If `cp_wheels.sh` detects an arch-specific wheel, it will refuse to copy it
unless the `--arch` flag is used. Choice of arch should match what was used
when building the wheel (see `build_wheel.sh`). `cp_wheels.sh` considers a
wheel to be arch-specific if it links external libraries not in the Gentoo or
Nix compatibility layer, or if any existing wheels for the same package are in
arch-specific directories in our wheelhouse.

-------------------------------------------------------------------------------
### `parbuild_wheel.sh`

**TODO**

-------------------------------------------------------------------------------
### `protobuf_optimized_wheel.sh`

**TODO**

-------------------------------------------------------------------------------
### `unmanylinuxize.sh`

A number of (difficult to build) Python packages are distributed as binary wheels
that are compatible with many common Linux distributions and therefore tagged 
with `manylinux` in the filename.  These are -- out of the box -- incompatible
with the CC software stack, because most of our libraries live in either the NIX
profile or Gentoo prefix.

However this script can download and patch `manylinux` wheels (basically by 
treating them with the `setrpaths.sh` script), thereby trying to make them 
compatible with the CC software stack.

```
Usage: unmanylinuxize.sh --package <package name> 
                        [--version <version>] 
                        [--python <comma separated list of python versions>]
```

-------------------------------------------------------------------------------
### `config/<package>.sh`

`build_wheel.sh` will try to source `${PACKAGE}-${VERSION}.sh` or `${PACKAGE}.sh` (whichever it finds first)
from the `config` directory, which allows for some package- and version- specific configurations.

To see examples on how to use these options, just grep through the `config/*.sh` files to find other recipes that use them.

Variable                    | Description
----------------------------|---------------------------------------------------
  `PACKAGE`                 | Name of the package. Defaults to the value of `--package`. 
  `VERSION`                 | Version of the package. Defaults to the value of `--version` or latest. 
  `PYTHON_VERSIONS`         | Comma separated list of Python versions, for which the wheel is to be built. Defaults to the value of `--python` (if set) or currently all installed python/3.x modules except 3.5.
`BDIST_WHEEL_ARGS`          | Extra arguments to pass to `python setup.py bdist_wheel $BDIST_WHEEL_ARGS`.
`MODULE_BUILD_DEPS`         | Loads these modules for building the wheel.
`MODULE_BUILD_DEPS_DEFAULT` | Is set to oldest-supported-numpy/.2022a python-build-bundle pytest/7.0.1 cython/.0.29.33 
`MODULE_RUNTIME_DEPS`       | Loads these modules for building and testing the wheel.
`MODULE_DEPS`               | **REMOVED** This variable is no longer used.
`NUMPY_DEFAULT_VERSION`     | Compile wheels against an older version of numpy to avoid making them incompatible with slightly older versions. Will switch to `oldest-supported-numpy` metapackage in the future.  
`PACKAGE_DOWNLOAD_CMD`      | Custom download command, e.g. `git clone ...`. (default: `pip download --no-cache --no-binary \$PACKAGE_DOWNLOAD_ARGUMENT --no-deps \$PACKAGE_DOWNLOAD_ARGUMENT`)
`PACKAGE_DOWNLOAD_ARGUMENT` | Additional argument to pass to `pip download`.
`PACKAGE_DOWNLOAD_NAME`     | In case downloaded name is different from `$PACKAGE`, e.g. `v${VERSION}.tar.gz` (default: `$PACKAGE`)
`PACKAGE_DOWNLOAD_METHOD`   | 
`PACKAGE_FOLDER_NAME`       | In case extracted folder has a name different from `$PACKAGE`. (default: `$PACKAGE`)
`PACKAGE_SUFFIX`            | Add this suffix to our package name, e.g. `-cpu` or `-gpu`. (default: "")
`PATCHES`                   | Applies these patch-files before building. Specify as a single or list of patch files, that have been placed in the `patches/` directory.
`PATCH_WHEEL_COMMANDS`      | Specify shell commands to patch a wheel in order to make it compatible with our stack.
`PRE_DOWNLOAD_COMMANDS`     | Specify shell commands to be executed before downloading the package.
`POST_DOWNLOAD_COMMANDS`    | Specify shell commands to be executed after downloading the package.
`PRE_BUILD_COMMANDS`        | Specify shell commands to be executed before downloading the package.
`POST_BUILD_COMMANDS`       | Specify shell commands to be executed after building the package.
`PRE_SETUP_COMMANDS`        | Specify shell commands to be executed before setting up build environment.
`PYTHON_DEPS`               | Installs these Python-dependencies into the virtualenv in addition to `PYTHON_DEPS_DEFAULT`.
`PYTHON_DEPS_DEFAULT`       | Is set to `""`.
`PYTHON_IMPORT_NAME`        | In case `import $NAME` is different from the package name, e.g. `PACKAGE=pyzmq` vs. `import zmq`. (default: `$PACKAGE`) 
`PYTHON_TESTS`              | String with Python command(s) to test the package. Executed after `import $PYTHON_IMPORT_NAME`.
`RPATH_ADD_ORIGIN`          | This will run `setrpaths.sh --path ${WHEEL_NAME} --add_origin`.
`RPATH_TO_ADD`              | This will run `setrpaths.sh --path ${WHEEL_NAME} --add_path $RPATH_TO_ADD`.
`TEST_COMMAND`              | Alternative shell command to test the wheel.
`UPDATE_REQUIREMENTS`       | One or more requirements to update. These will be changed by `manipulate_wheels.py` after the wheel is done building.

### `manipulate_wheels.py`
#### Usage
```bash
$ ./manipulate_wheels.py -h

usage: manipulate_wheels [-h] -w WHEELS [WHEELS ...] [-i] [-u UPDATE_REQ [UPDATE_REQ ...]] [-a ADD_REQ [ADD_REQ ...]] [--set_min_numpy SET_MIN_NUMPY] [--inplace] [--force] [-p] [-v] [-t TAG]

Manipulate wheel files

optional arguments:
  -h, --help            show this help message and exit
  -w WHEELS [WHEELS ...], --wheels WHEELS [WHEELS ...]
                        Specifies which wheels to patch (default: None)
  -i, --insert_local_version
                        Adds the +computecanada local version (default: False)
  -u UPDATE_REQ [UPDATE_REQ ...], --update_req UPDATE_REQ [UPDATE_REQ ...]
                        Updates requirements of the wheel. (default: None)
  -a ADD_REQ [ADD_REQ ...], --add_req ADD_REQ [ADD_REQ ...]
                        Add requirements to the wheel. (default: None)
  --set_min_numpy SET_MIN_NUMPY
                        Sets the minimum required numpy version. (default: None)
  --inplace             Work in the same directory as the existing wheel instead of a temporary location (default: False)
  --force               If combined with --inplace, overwrites existing wheel if the resulting wheel has the same name (default: False)
  -p, --print_req       Prints the current requirements (default: False)
  -v, --verbose         Displays information about what it is doing (default: False)
  -t TAG, --add_tag TAG
                        Specifies a tag to add to wheels (default: None)
```

#### Examples
Insert local tag (`computecanada`) :
```bash
$ ./manipulate_wheels.py -i -w wheel-0.2.2-py3-none-any.whl 
Resulting wheels will be in directory ./tmp
New wheel created tmp/wheel-0.2.2+computecanada-py3-none-any.whl
```

Work inplace:
```bash
$ ./manipulate_wheels.py --inplace -i -w wheel-0.2.2-py3-none-any.whl 
New wheel created wheel-0.2.2+computecanada-py3-none-any.whl
```

Rename a requirement, and update a requirement version:
**Note**: the special separator `->` in order to rename a requirement.
```bash
$ ./manipulate_wheels.py -v -w wheel-0.2.2-py3-none-any.whl -u "faiss-cpu->faiss" "tensorflow (>=2.2.2)"
Resulting wheels will be in directory ./tmp
wheel-0.2.2-py3-none-any.whl: updating requirement faiss-cpu to faiss
wheel-0.2.2-py3-none-any.whl: updating requirement tensorflow (>=2.2.0) to tensorflow (>=2.2.2)
New wheel created tmp/wheel-0.2.2-py3-none-any.whl
```
