MODULE_BUILD_DEPS="cuda/11.7 cudnn cmake protobuf/3.21.3"
# Set TORCH_VERSION in your shell to build with a specific version or latest/current by default.
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION} protobuf==4.21.3"
PRE_BUILD_COMMANDS="
	export BUILD_VERSION=$VERSION;
	export PYTORCH_VERSION=\$(python -c 'import torch; print(torch.__version__)');
"
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pytorch/text@v${VERSION:?version required}"
