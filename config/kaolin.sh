PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/NVIDIAGameWorks/kaolin/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PYTHON_DEPS='cython~=0.29.37 torch<2.6.0'
MODULE_BUILD_DEPS='cuda/12'
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='8.0;8.6;9.0';
	export FORCE_CUDA=1;
	sed -i 's/get_requirements(),/get_requirements() + [\"torch\"],/' setup.py;
"
