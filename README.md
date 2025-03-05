# wheels_builder

Scripts to automate building Python wheels for DRAC's wheelhouse.

**Table of Content:**

* [Quick Start]
  * [`build_wheel.sh`](./docs/#build_wheelsh)
  * [`wheel_architecture.sh`](./docs/#wheel_architecturesh)
  * [`cp_wheels.sh`](./docs/#cp_wheelssh)
  * [`parbuild_wheel.sh`](./docs/#parbuild_wheelsh)
  * [`unmanylinuxize.sh`](#unmanylinuxizesh)
  * [`config/<package>.sh`](#configpackagesh)
  * [`manipulate_wheels.py`](#manipulate_wheelspy)


## Quick Start


### `unmanylinuxize.sh`

Note: prefer to build with `build_wheels.sh` (and source) when possible.

A number of (difficult to build) Python packages are distributed as binary wheels
that are compatible with many common Linux distributions and therefore tagged 
with `manylinux` in the filename. These are -- out of the box -- incompatible
with the software stack, because most of our libraries live in different locations.

However this script can download and patch `manylinux` wheels (basically by 
treating them with the `setrpaths.sh` script), thereby trying to make them 
compatible with the software stack.

```
Usage: unmanylinuxize.sh 
  --package <package name> 
  [--version <version>]
  [--python <comma separated list of python versions>]
  [--add_path <add rpath>]
  [--add_origin <add origin to rpath>]
  [--find_links https://index.url | --url https://direct.url.to.wheel.whl ]
```

`--find-links` set `PIP_FIND_LINKS` and can be useful to search an alternative index then PyPI.
`--url` allows one to directly download a specific wheel file with `wget`

-------------------------------------------------------------------------------
### `config/<package>.sh`

`build_wheel.sh` will try to source (case insensitively) `${PACKAGE}-${VERSION}.sh` then `${PACKAGE}.sh`
from the `config` directory, which allows for some package- and version- specific configurations. 

To see examples on how to use these options, just `grep` through the `config/*.sh` files to find other recipes that use them.

Variable                    | Description
----------------------------|---------------------------------------------------
  `PACKAGE`                 | Name of the package. Defaults to the value of `--package`. 
  `VERSION`                 | Version of the package. Defaults to the value of `--version` or latest. 
  `PYTHON_VERSIONS`         | List of Python versions, for which the wheel is to be built. Defaults to the value of `--python` (if set) or default python versions (ie 3.11,3.12,3.13).
`BDIST_WHEEL_ARGS`          | Extra arguments to pass to `python setup.py bdist_wheel $BDIST_WHEEL_ARGS`.
`PIP_WHEEL_ARGS`            | Extra arguments to pass to `pip wheel $PIP_WHEEL_ARGS`. 
`MODULE_BUILD_DEPS`         | Loads these modules for building the wheel.
`MODULE_BUILD_DEPS_DEFAULT` | Is set to `numpy/.2.1.1 python-build-bundle pytest cython/.3.0.11`
`MODULE_RUNTIME_DEPS`       | Loads these modules for building and testing the wheel.
`PACKAGE_DOWNLOAD_CMD`      | Custom download command, e.g. `git clone ...`. (default: `pip download --no-cache --no-binary \$PACKAGE_DOWNLOAD_ARGUMENT --no-deps \$PACKAGE_DOWNLOAD_ARGUMENT`)
`PACKAGE_DOWNLOAD_ARGUMENT` | Additional argument to pass to `pip download`.
`PACKAGE_DOWNLOAD_NAME`     | In case downloaded name is different from `$PACKAGE`, e.g. `v${VERSION}.tar.gz` (default: `$PACKAGE`)
`PACKAGE_DOWNLOAD_METHOD`   | Use `pip download` (default) or specify `Git`
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
usage: manipulate_wheels [-h] -w WHEELS [WHEELS ...] [-i] [-u UPDATE_REQ [UPDATE_REQ ...]] [-a ADD_REQ [ADD_REQ ...]] [-r REMOVE_REQ [REMOVE_REQ ...]] [--set_min_numpy SET_MIN_NUMPY] [--set_lt_numpy SET_LT_NUMPY] [--inplace] [--force] [-p] [-v] [-t TAG]

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
  -r REMOVE_REQ [REMOVE_REQ ...], --remove_req REMOVE_REQ [REMOVE_REQ ...]
                        Remove requirements from the wheel. (default: None)
  --set_min_numpy SET_MIN_NUMPY
                        Sets the minimum required numpy version. (default: None)
  --set_lt_numpy SET_LT_NUMPY
                        Sets the lower than (<) required numpy version. (default: None)
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
