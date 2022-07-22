# Must use git as archive have no setup.py that satisfy pip.
# Versioning is all over the place for protobuf, tag v21.3/v3.21.3 is python protobuf 4.21.3 for instance.

# When possible, build the module, but provide this config other version for an optimized wheel.
# Wheel will be avx2
PACKAGE="protobuf"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_FOLDER_NAME=$PACKAGE
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/protocolbuffers/protobuf"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"
MODULE_BUILD_DEPS="cmake"
PYTHON_IMPORT_NAME="google.protobuf"
PRE_BUILD_COMMANDS="
	cmake -B build -S cmake -DBUILD_SHARED_LIBS=OFF -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=\$PWD/src -DCMAKE_CXX_FLAGS='-fPIC' -DCMAKE_VERBOSE_MAKEFILE=ON &&
	cmake --build build --parallel 4 &&
	cmake --install build &&
	mv src/lib64 src/.libs &&
	export PROTOC=\$PWD/src/bin/protoc &&
	cd python;
"
BDIST_WHEEL_ARGS="-v --cpp_implementation --compile_static_extension"
