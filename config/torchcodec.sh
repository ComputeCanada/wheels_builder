MODULE_BUILD_DEPS='cuda/13.2 protobuf abseil'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/torchcodec/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PYTHON_DEPS="torch>=2.7.0 setuptools>77.0.0 torch${TORCH_VERSION:+==$TORCH_VERSION}"
PRE_BUILD_COMMANDS='
        export ENABLE_CUDA=1;
        export I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION=1;
        export TORCH_CUDA_ARCH_LIST="8.0;9.0;10.0+PTX";
        export CMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH:$(python3 -c '\''import pybind11; print(pybind11.get_cmake_dir())'\'')";
        export CXXFLAGS="-Wno-error=restrict";
'
