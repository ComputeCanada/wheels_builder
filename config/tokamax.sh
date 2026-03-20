if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
	POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --remove_req nvidia-cudnn-cu12 -w $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
elif [[ $THIS_SCRIPT == 'unmanylinuxize.sh' ]]; then
	PATCH_WHEEL_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --remove_req nvidia-cudnn-cu12 -w $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
fi
