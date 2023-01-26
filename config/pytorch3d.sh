MODULE_BUILD_DEPS="cuda/11.4 opencv"
PYTHON_DEPS="torch"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/facebookresearch/pytorch3d/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS='
	export FORCE_CUDA=1;
	export TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0;8.6";
	export CUB_HOME=$CUDA_ROOT/include/cub;
	sed -i -e "s/install_requires=/install_requires=[\"torch\"]\+/" setup.py
'
RPATH_TO_ADD="'\$ORIGIN/../torch/lib'"
TEST_COMMAND="python -c 'import pytorch3d; from pytorch3d import _C'"
