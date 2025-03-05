# configurations

Configuration file are useful to provide customization or specific steps/actions needed for a wheel to be built.
One can create version specific configuration using: `package-version.sh` or general one using: `package.sh`.

`build_wheel.sh` will try to source (case insensitively) in the following order:
1. `${PACKAGE}-${VERSION}.sh` then;
2. `${PACKAGE}.sh`

from the `config` directory.

To see examples on how to use these options, just `grep` through the [`config/*.sh`](https://github.com/ComputeCanada/wheels_builder/tree/main/config) files to find other recipes that use them.

# Variables

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
