# The root of repo does not contains a setup nor pyproject. Use git instead.
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/rapidsai/rmm.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"

PYTHON_DEPS="scikit-build>=0.13.1 cuda-python>=11.7.1,<12.0 cython ninja"
MODULE_BUILD_DEPS="cmake cuda/11.7 spdlog"
PRE_BUILD_COMMANDS="
	export RAPIDS_PY_WHEEL_VERSIONEER_OVERRIDE=$VERSION;
	cd python;
	sed -i -e 's/version=\".*\"/version=\"$VERSION\"/' setup.py;
"
