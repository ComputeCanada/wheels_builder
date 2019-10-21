if [[ "$RSNT_ARCH" == "avx" ]]; then
	MODULE_BUILD_DEPS="gcc/5.4.0 hdf5"
else
	MODULE_BUILD_DEPS="gcc/7.3.0 hdf5"
fi
PYTHON_DEPS="nose numpy six Cython unittest2"
PYTHON_TESTS="h5py.run_tests()"

