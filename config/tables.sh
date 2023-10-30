MODULE_BUILD_DEPS="hdf5 blosc2"
PYTHON_DEPS="h5py numexpr six nose mock packaging blosc2"
PYTHON_TESTS="tables.test()"
PRE_BUILD_COMMANDS='
	rm -r c-blosc/{blosc,internal-complibs};
	sed -i "s@/usr/local@$EBROOTGENTOO@" setup.py;
'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/PyTables/PyTables/archive/refs/tags/v${VERSION:?version required}.tar.gz"
