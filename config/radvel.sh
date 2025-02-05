PRE_BUILD_COMMANDS="
    sed -i -e '/cython/d' -e 's/[=>]=.*$//' requirements.txt;
"
POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req h5py -w $WHEEL_NAME'
