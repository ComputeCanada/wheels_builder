# MACH-AERO pyOptSparse
# https://mdolab-pyoptsparse.readthedocs-hosted.com/en/latest/
PYTHON_IMPORT_NAME='pyoptsparse'
MODULE_BUILD_DEPS='oldest-supported-numpy/.2024a -numpy/.2.1.1 ipopt'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mdolab/pyoptsparse/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS='
	export IPOPT_DIR=$EBROOTIPOPT;
'
# Fix tags
POST_BUILD_COMMANDS='PYVER=${EBVERSIONPYTHON::-2}; wheel tags --remove --abi-tag=cp${PYVER//.} --python-tag=cp${PYVER//.} --platform-tag=linux_x86_64 $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
