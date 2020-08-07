MODULE_BUILD_DEPS="gcc/7.3.0 boost bullet qt/5.6.1"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/openai/roboschool/archive/1.0.46.tar.gz"
PACKAGE_DOWNLOAD_NAME="1.0.46.tar.gz"
PACKAGE_FOLDER_NAME="roboschool-1.0.46"
PRE_BUILD_COMMANDS="pushd roboschool/cpp-household && make && popd "
if [[ "$RSNT_ARCH" == "avx2" ]]; then
	export CFLAGS="-march=core-avx2"
elif [[ "$RSNT_ARCH" == "avx512" ]]; then
	export CFLAGS="-march=skylake-avx512"
fi
PATCHES="roboschool-cpp-household.patch"
