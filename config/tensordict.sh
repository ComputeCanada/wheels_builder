PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/tensordict/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
