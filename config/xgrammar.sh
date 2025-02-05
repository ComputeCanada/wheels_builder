PRE_BUILD_COMMANDS='
	cmake -B _build;
	cmake --build _build --parallel ${SLURM_CPUS_PER_TASK:-1};
	cd python;
'
PYTHON_DEPS="torch"
POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req triton -w $WHEEL_NAME'

PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mlc-ai/xgrammar.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
