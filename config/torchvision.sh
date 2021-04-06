PYTHON_DEPS="numpy six pillow-simd torch"
MODULE_BUILD_DEPS="gcc/8.4.0 cuda/10.2"
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pytorch/vision.git@v$VERSION"
PRE_BUILD_COMMANDS="export BUILD_VERSION=$VERSION; export TORCH_CUDA_ARCH_LIST='3.5;3.7;6.0;7.0'; export FORCE_CUDA=1; export MAX_JOBS=16"
