MODULE_BUILD_DEPS="arrow/8 cmake boost flatbuffers thrift"
MODULE_RUNTIME_DEPS="arrow/8"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/nanoporetech/pod5-file-format.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch ${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PYTHON_DEPS="build setuptools setuptools_scm[toml]"
# The root pyproject is for pod5version that creates a version file when built, which then requires a custom script to create a version file
# in order for the cmake to run without error.........................
PRE_BUILD_COMMANDS="
	python -m build . -x -n -s &&
	python pod5_make_version.py &&
	cmake -B build . -DPOD5_BUILD_EXAMPLES=OFF &&
	cmake --build build -- -j 4 &&
	cd python/lib_pod5
"
