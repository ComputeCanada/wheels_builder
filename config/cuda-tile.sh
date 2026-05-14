MODULE_BUILD_DEPS='cuda/12.9'
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/NVIDIA/cutile-python.git@v${VERSION:?version required}"
PRE_BUILD_COMMANDS="
	sed -i '/-DCMAKE_BUILD_TYPE=/a\\                     f\"-DCUDAToolkit_ROOT=${CUDA_HOME}\",' setup.py;
	echo "$VERSION" > src/cuda/tile/VERSION;
"
PYTHON_DEPS="setuptools==80.10.2"
