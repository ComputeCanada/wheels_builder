POST_BUILD_COMMANDS='
    $SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req h5py -w $WHEEL_NAME
'
