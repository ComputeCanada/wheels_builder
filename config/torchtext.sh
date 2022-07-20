PYTHON_DEPS="torch==1.10.0"
PRE_BUILD_COMMANDS="export BUILD_VERSION=\$VERSION"
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pytorch/text.git@v${VERSION:?version required}-rc3"
UPDATE_REQUIREMENTS="'torch (==1.10.0)'"
