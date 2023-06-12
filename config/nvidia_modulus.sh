PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/NVIDIA/modulus/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS='sed -i "s/nvidia_dali_cuda110/nvidia_dali/" setup.py pyproject.toml'
PYTHON_IMPORT_NAME="modulus"
MODULE_RUNTIME_DEPS='arch/avx2'
