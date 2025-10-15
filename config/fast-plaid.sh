PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/lightonai/fast-plaid/archive/refs/tags/${VERSION:?version required}.tar.gz"
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION} maturin>=1.8.6 setuptools>=78.1.1"
POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --remove_req maturin -w $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
