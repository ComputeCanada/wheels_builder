MODULE_BUILD_DEPS='cuda/12.6 protobuf abseil'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/torchcodec/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PYTHON_DEPS='torch>=2.7.0'
PRE_BUILD_COMMANDS='
        export ENABLE_CUDA=1;
        export I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION=1;
        export TORCH_CUDA_ARCH_LIST="7.0;8.0;9.0";
'
