PYTHON_DEPS="torch>=1.10.0 torchvision"
MODULE_RUNTIME_DEPS="gcc/9.3.0 cuda/11.4 opencv"
PRE_BUILD_COMMANDS="export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0'; export FORCE_CUDA=1; export MAX_JOBS=8"
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/facebookresearch/detectron2.git@v$VERSION"
