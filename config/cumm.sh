PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/FindDefinition/cumm/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PYTHON_DEPS="pccm>=0.4.2"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS='cuda/12.6'
else
	MODULE_BUILD_DEPS='cuda/11.7'
fi
PRE_BUILD_COMMANDS="
	export CUMM_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6;9.0';
	export CUMM_DISABLE_JIT="1";
"
