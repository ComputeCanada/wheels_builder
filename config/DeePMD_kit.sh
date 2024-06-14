MODULE_BUILD_DEPS="cuda/12"
MODULE_RUNTIME_DEPS="openmpi mpi4py"
PYTHON_DEPS="tensorflow scikit-build"
PRE_BUILD_COMMANDS="export DP_VARIANT=cuda;"
RPATH_TO_ADD="'\$ORIGIN/../../tensorflow'"
UPDATE_REQUIREMENTS='tensorflow-cpu -> tensorflow'
