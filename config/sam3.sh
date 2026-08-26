POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req triton psutil -w $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
