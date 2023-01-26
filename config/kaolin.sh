PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/NVIDIAGameWorks/kaolin/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PYTHON_DEPS='cython==0.29.20 torch<1.13.0'
MODULE_BUILD_DEPS='cuda/11.4'
PRE_BUILD_COMMANDS="export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6'; sed -i 's/get_requirements(),/get_requirements() + [\"torch\"],/' setup.py"
