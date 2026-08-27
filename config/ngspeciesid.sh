# This package only provides an NGSpeciesID script, no module
PYTHON_IMPORT_NAME=""
TEST_COMMAND="NGSpeciesID --help"
MODULE_RUNTIME_DEPS="parasail"
# Unpin Parasail 1.2.4 to use the 2.* module-provided extension instead
POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --update_req parasail -w $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
