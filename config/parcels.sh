MODULE_RUNTIME_DEPS='openmpi mpi4py'
POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req mpi4py -w $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
