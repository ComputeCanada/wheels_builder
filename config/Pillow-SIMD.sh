if [[ -z "$EBROOTGENTOO" ]]; then
	PRE_BUILD_COMMANDS="export CC=\"cc -mavx2\""
else
	PRE_BUILD_COMMANDS="export CC=\"cc -mavx2\"; export CFLAGS=\"-I/cvmfs/soft.computecanada.ca/gentoo/2020/usr/include -L/cvmfs/soft.computecanada.ca/gentoo/2020/usr/lib64 \""
fi
PYTHON_IMPORT_NAME="PIL"
