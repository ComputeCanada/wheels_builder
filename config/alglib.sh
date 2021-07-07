PACKAGE_DOWNLOAD_ARGUMENT="https://www.alglib.net/translator/re/alglib-$VERSION.cpython.free.zip"
PRE_BUILD_COMMANDS="sed -i -E \"/name\s+=\s+'alglib',/a version='$VERSION',\" setup.py"
PYTHON_IMPORT_NAME="xalglib"
PYTHON_TESTS="s = xalglib.minlbfgscreate(2,[0,0,0])"
