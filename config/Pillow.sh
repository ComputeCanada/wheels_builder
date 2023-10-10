PYTHON_IMPORT_NAME="PIL"
if [[ -z $EBROOTGENTOO ]]; then
	PRE_BUILD_COMMANDS="sed -i -e 's;/sbin/ldconfig;ldconfig;g' setup.py && CPATH=$NIXUSER_PROFILE/include:$CPATH "
else
	PRE_BUILD_COMMANDS='
		sed -i -e "s;/sbin/ldconfig;ldconfig;g" setup.py;
		CPATH=$EBROOTGENTOO/include:$CPATH;
		LIBRARY_PATH=$EBROOTGENTOO/lib:$LIBRARY_PATH;
		python setup.py build_ext --inplace --enable-raqm;
	'
fi
MODULE_BUILD_DEPS="raqm"
TEST_COMMAND="python -c 'import PIL; from PIL import features; assert features.check(\"freetype2\"); assert features.check(\"raqm\")'"
