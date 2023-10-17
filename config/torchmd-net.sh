PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/torchmd/torchmd-net/archive/refs/tags/${VERSION:?version required}.tar.gz"
MODULE_BUILD_DEPS="cuda/11.7"
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PYTHON_IMPORT_NAME='torchmdnet'
PRE_BUILD_COMMANDS="sed -i -e \"s/version=version/version='$VERSION'/\" setup.py"
