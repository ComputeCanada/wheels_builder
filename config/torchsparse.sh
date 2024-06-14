PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mit-han-lab/torchsparse/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS='
	export TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0;8.6;9.0";
	export FORCE_CUDA=1;
	sed -i -e "s/__version__.*/__version__ = \"$VERSION\"/" torchsparse/version.py
'
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION} tqdm"
MODULE_BUILD_DEPS='sparsehash cuda'
