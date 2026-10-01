if [[ "$EBVERSIONGENTOO" -ge 2023 ]]; then
	MODULE_BUILD_DEPS="cuda/13 cudnn cmake protobuf abseil"
else
    MODULE_BUILD_DEPS="gcc/9 cuda/11.7 cudnn cmake protobuf/3.21.3"
fi
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
# torchaudio 2.11 is now in maintenance only and abi3 compatible.
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pytorch/audio@245ccb4"
PACKAGE_DOWNLOAD_METHOD="Git"?
PRE_BUILD_COMMANDS='
    export BUILD_VERSION=$VERSION;
    export TORCH_CUDA_ARCH_LIST="8.0;9.0;10.0+PTX";
'
RPATH_ADD_ORIGIN="yes"
