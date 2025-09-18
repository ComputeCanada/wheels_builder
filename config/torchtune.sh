MODULE_RUNTIME_DEPS='arrow'
PYTHON_DEPS="torchao"
POST_BUILD_COMMANDS='
    $SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req torchao -w $WHEEL_NAME
'


