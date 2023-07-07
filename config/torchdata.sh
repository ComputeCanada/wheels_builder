PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/data/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PRE_BUILD_COMMANDS="export USE_SYSTEM_LIBS=1; export BUILD_VERSION=$VERSION;"
