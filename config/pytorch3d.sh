if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12.2 opencv/4.8"
	PATCHES='pytorch3d-fix-float3-cuda12.patch'
else
	MODULE_BUILD_DEPS="cuda/11.4 opencv"
fi
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/facebookresearch/pytorch3d/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS='
	export FORCE_CUDA=1;
	export TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0;8.6";
	export CUB_HOME=$CUDA_ROOT/include/cub;
	sed -i -e "s/install_requires=/install_requires=[\"torch\"]\+/" setup.py
'
RPATH_TO_ADD="'\$ORIGIN/../torch/lib'"
TEST_COMMAND="python -c 'import pytorch3d; from pytorch3d import _C'"
