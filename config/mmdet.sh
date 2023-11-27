MODULE_RUNTIME_DEPS="opencv"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
    MODULE_BUILD_DEPS="cuda/12.2"
else
    MODULE_BUILD_DEPS="cuda/11.4"
fi
PRE_BUILD_COMMANDS="export FORCE_CUDA=1;"
PYTHON_DEPS="torch>=1.10.0 mmcv rich termcolor"
