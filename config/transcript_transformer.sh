MODULE_RUNTIME_DEPS='arrow'
POST_BUILD_COMMANDS='
    $SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req torch -w $WHEEL_NAME
'

