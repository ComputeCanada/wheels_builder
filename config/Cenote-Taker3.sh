PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mtisza1/Cenote-Taker3/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PYTHON_IMPORT_NAME='cenote'
POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req pyhmmer -w $WHEEL_NAME'
