MODULE_BUILD_DEPS='cuda/12.9'
PYTHON_DEPS='cuda-bindings==12.9.*'
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/NVIDIA/nvmath-python@v${VERSION:?version required}"
