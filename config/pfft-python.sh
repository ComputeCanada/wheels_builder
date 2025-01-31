MODULE_BUILD_DEPS="cython/.0.29.36"
MODULE_RUNTIME_DEPS="gcc openmpi mpi4py"
PYTHON_IMPORT_NAME="pfft"
POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --remove_req cython -w $WHEEL_NAME'
