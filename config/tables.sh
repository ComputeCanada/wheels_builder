MODULE_BUILD_DEPS="hdf5 blosc2"
# PYTHON_DEPS="h5py numexpr six nose mock packaging"
PYTHON_TESTS="tables.test()"

# Tables assumes blosc2 wheel provides libblosc2, but it does not in our case.
# It also expects the lib to be under `tables/libblosc2.so`, but it does not.
# Instead of relying on the find_library mechanism, make it already found (it is in the rpath).
# Do not use the blosc2 under hdf5 which is incompatible, hint and link to a correct version of blosc2.
PRE_BUILD_COMMANDS='
	rm -r c-blosc/{blosc,internal-complibs};
	sed -i "s@/usr/local@$EBROOTGENTOO@" setup.py;
    sed -i -e "s/blosc2_found = False/blosc2_found = True/" tables/__init__.py;
    export CPATH=$EBROOTGENTOO/include:$CPATH;
    export BLOSC2_DIR=$EBROOTBLOSC2;
    export PYTABLES_NO_BLOSC2_WHEEL=1;
    export LFLAGS="-L $EBROOTBLOSC2/lib $EBROOTBLOSC2/lib/libblosc2.so"
'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/PyTables/PyTables.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
