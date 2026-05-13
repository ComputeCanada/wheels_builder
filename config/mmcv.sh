PYTHON_DEPS="torch>=1.10.0 ninja rich termcolor"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
    MODULE_BUILD_DEPS="cuda/12.9"
else
    MODULE_BUILD_DEPS="cuda/11.4"
fi
MODULE_RUNTIME_DEPS='opencv'
PRE_BUILD_COMMANDS="export MMCV_WITH_OPS=1; export FORCE_CUDA=1; export TORCH_CUDA_ARCH_LIST='8.0;9.0+PTX'; export MAX_JOBS=${SLURM_CPUS_PER_TASK:-1};"
PYTHON_IMPORT_NAME='mmcv'
PYTHON_TEST='from mmcv.ops import sigmoid_focal_loss'
