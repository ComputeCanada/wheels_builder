PYTHON_DEPS="torch==1.7.1 torchvision==0.8.2"
MODULE_RUNTIME_DEPS="gcc/9.3.0 cuda/11 opencv"
PRE_BUILD_COMMANDS="export TORCH_CUDA_ARCH_LIST='3.5;3.7;6.0;7.0'; export FORCE_CUDA=1; export MAX_JOBS=8"
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/facebookresearch/detectron2.git@v$VERSION"
