PRE_BUILD_COMMANDS='module load flexiblas/3.0.4; echo "[DEFAULT]" > site.cfg; echo "library_dirs = $EBROOTFLEXIBLAS/lib" >> site.cfg; echo "include_dirs = $EBROOTFLEXIBLAS/include/flexiblas" >> site.cfg; echo "[atlas]" >> site.cfg; echo "atlas_libs = flexiblas" >> site.cfg; echo "[lapack]" >> site.cfg; echo "lapack_libs = flexiblas" >> site.cfg'
MODULE_BUILD_DEPS="arch/sse3 flexiblas/3.0.4"
PYTHON_DEPS="nose pytest cython hypothesis"
PYTHON_DEPS_DEFAULT=""
PYTHON_TESTS="numpy.__config__.show(); numpy.test()"

