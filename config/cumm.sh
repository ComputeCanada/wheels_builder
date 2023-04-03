PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/FindDefinition/cumm/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PYTHON_DEPS="pccm>=0.4.2"
MODULE_BUILD_DEPS='cuda/11.4'
PRE_BUILD_COMMANDS="
	export CUMM_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
	export CUMM_DISABLE_JIT="1";
"
