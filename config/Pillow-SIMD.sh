if [[ -z "$EBROOTGENTOO" ]]; then
	PRE_BUILD_COMMANDS="export CC=\"cc -mavx2\""
else
	PRE_BUILD_COMMANDS='
		export CC="cc -mavx2";
		sed -i -e "s;/sbin/ldconfig;ldconfig;g" setup.py;
		CPATH=$EBROOTGENTOO/include:$CPATH;
		LIBRARY_PATH=$EBROOTGENTOO/lib:$LIBRARY_PATH;
		python setup.py build_ext --inplace --enable-raqm;
	'
fi
PYTHON_IMPORT_NAME="PIL"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/uploadcare/pillow-simd/archive/refs/tags/v${VERSION:?version required}.tar.gz"
MODULE_BUILD_DEPS="arch/avx2 raqm/0.9.0"
TEST_COMMAND="python -c 'import PIL; from PIL import features; assert features.check(\"freetype2\"); assert features.check(\"raqm\")'"
