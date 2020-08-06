# ComputeCanada/wheels\_builder

Scripts to automate building Python wheels for Compute Canada's wheelhouse.


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
```


### `wheel_architecture.sh`

Analyzes the content of the wheel and makes some prediction into which subtree
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

### `cp_wheels.sh`

Copies all wheels in the current directory to the predicted location in the wheelhouse
after adjusting the permissions. 

```
Usage: cp_wheels.sh [--wheel <wheel file>] [--remove] [--dry-run]

   --wheel <wheel file>   Process only this wheel (otherwise all in the $CWD)
   --remove               Delete the wheel after copying.
   --dry-run              Just print the commands, but don't execute anything.
```


### `config/<package>.sh`

`build_wheel.sh` will try to source `${PACKAGE}-${VERSION}.sh` or `${PACKAGE}.sh` from the `config` 
directory, which allows for some package- and version- specific configutations.


* `BDIST_WHEEL_ARGS`          : 
* `MODULE_BUILD_DEPS`         : Loads these modules for building the wheel.
* `MODULE_DEPS`               : 
* `MODULE_RUNTIME_DEPS`       : Loads these modules for testing the wheel.
* `PACKAGE`                   : Name of the package. Defaults to the value of `--package`. 
* `PACKAGE_DOWNLOAD_ARGUMENT` : 
* `PACKAGE_DOWNLOAD_CMD`      : 
* `PACKAGE_DOWNLOAD_METHOD`   : 
* `PACKAGE_DOWNLOAD_NAME`     : 
* `PACKAGE_FOLDER_NAME`       : 
* `PACKAGE_SUFFIX`            : 
* `PATCHES`                   : Applies these patch-files before building. 
* `PATCH_WHEEL_COMMANDS`      : 
* `POST_BUILD_COMMANDS`       : 
* `POST_DOWNLOAD_COMMANDS`    : 
* `PRE_BUILD_COMMANDS`        : 
* `PRE_DOWNLOAD_COMMANDS`     : 
* `PYTHON_DEPS`               : Installs these Python-dependencies into the virtualenv in addition to `PYTHON_DEPS_DEFAULT`.
* `PYTHON_DEPS_DEFAULT`       : Is set to "numpy scipy cython" because these packages are needed by so many packages.
* `PYTHON_IMPORT_NAME`        : In case `import name` is different from the package name (e.g. `PACKAGE=pyzmq` vs. `import zmq`. Defaults to `$PACKAGE`. 
* `PYTHON_TESTS`              : 
* `PYTHON_VERSIONS`           : Comma separated list of Python versions, for which the wheel is to be built. Defaults to the value of `--python` (if set) or currently all installed python/3.x modules except 3.5.
* `RPATH_ADD_ORIGIN`          : 
* `RPATH_TO_ADD`              : This will run `setrpaths.sh --path filename.whl --add_path $RPATH_TO_ADD`.  
* `TEST_COMMAND`              : 
* `VERSION`                   : 


