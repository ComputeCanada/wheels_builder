MODULE_BUILD_DEPS="cuda/11.4 cudnn cmake protobuf/3.21.3"
PYTHON_DEPS="torch protobuf==4.21.3"
PRE_BUILD_COMMANDS="export BUILD_VERSION=$VERSION; export PYTORCH_VERSION=\$(python -c 'import torch; print(torch.__version__)'); "
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pytorch/text@v${VERSION:?version required}"
