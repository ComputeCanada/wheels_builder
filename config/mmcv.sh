PYTHON_DEPS="torch>=1.10.0 ninja rich termcolor"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
    MODULE_BUILD_DEPS="cuda/12.2"
else
    MODULE_BUILD_DEPS="cuda/11.4"
fi
MODULE_RUNTIME_DEPS='opencv'
PRE_BUILD_COMMANDS="export MMCV_WITH_OPS=1; export FORCE_CUDA=1; export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6;9.0'; export MAX_JOBS=4;"
PYTHON_IMPORT_NAME='mmcv'
PYTHON_TEST='from mmcv.ops import sigmoid_focal_loss'
