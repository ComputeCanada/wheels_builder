TORCH_VERSION=1.12.0
MODULE_BUILD_DEPS="cuda/11.4"
PYTHON_DEPS="torch==$TORCH_VERSION"
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
	sed -i -e 's#${VERSION:?version required}#$VERSION+torch${TORCH_VERSION//./}#' torchlars/__version__.py;
"
UPDATE_REQUIREMENTS="'torch (==$TORCH_VERSION)'"
