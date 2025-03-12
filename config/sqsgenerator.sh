MODULE_BUILD_DEPS='boost/1.85 oldest-supported-numpy/.2024a -numpy/.2.1.1'
# Python bindings and numpy generated via boost. Ensure we pin numpy<2 as boost 1.85 support only 1.x
PRE_BUILD_COMMANDS='
	export SQS_USE_MPI=ON;
	sed -i -e "s/numpy/numpy<2/" setup.py
'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/dgehringer/sqsgenerator/archive/refs/tags/v${VERSION:?version required}.tar.gz"
