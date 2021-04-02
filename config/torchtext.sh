PYTHON_DEPS="torch"
PRE_BUILD_COMMANDS="export BUILD_VERSION=\$VERSION"
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pytorch/text.git@v$VERSION-rc1"
