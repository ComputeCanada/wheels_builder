# Must use git as archive have no setup.py that satisfy pip.
# Versioning is all over the place for protobuf, tag v21.3/v3.21.3 is python protobuf 4.21.3 for instance.

# When possible, build the module, but provide this config other version for an optimized wheel.
# Wheel will be avx2

PYTHON_IMPORT_NAME="google.protobuf"

# New upb implemantation is faster, and c++ api was deprecated in 4.21
if [[ $(translate_version $VERSION) -le $(translate_version '4.21.0')  ]]; then
	PACKAGE="protobuf"
	PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
	PACKAGE_FOLDER_NAME=$PACKAGE
	PACKAGE_DOWNLOAD_METHOD="Git"
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/protocolbuffers/protobuf"
	PACKAGE_DOWNLOAD_CMD="git clone --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
	POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"
	MODULE_BUILD_DEPS="cmake"
	PRE_BUILD_COMMANDS='
		cmake -B . -S cmake -DBUILD_SHARED_LIBS=OFF -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=$PWD -DCMAKE_CXX_FLAGS="-fPIC" -DCMAKE_VERBOSE_MAKEFILE=ON &&
		cmake --build . --parallel 4 &&
		cmake --install . &&
		export PROTOC=$PWD/bin/protoc &&
		cd python &&
		sed -i -e "s#/src/.libs##" setup.py;
	'
	BDIST_WHEEL_ARGS="-v --cpp_implementation --compile_static_extension"
	TEST_COMMAND="python -c 'import $PYTHON_IMPORT_NAME; from $PYTHON_IMPORT_NAME.pyext import _message'"
else
	TEST_COMMAND="python -c 'import $PYTHON_IMPORT_NAME; from google import _upb'"
fi
