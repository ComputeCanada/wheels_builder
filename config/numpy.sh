# One could also set NPY_BLAS_LIBS, NPY_LAPACK_LIBS and NPY_CBLAS_LIBS since numpy 1.21.
PRE_BUILD_COMMANDS='module load flexiblas/3.0.4;
echo "[DEFAULT]" > site.cfg;
echo "library_dirs = $EBROOTFLEXIBLAS/lib" >> site.cfg;
echo "include_dirs = $EBROOTFLEXIBLAS/include/flexiblas" >> site.cfg;
echo "[atlas]" >> site.cfg;
echo "libraries = flexiblas" >> site.cfg;
echo "[blis]" >> site.cfg;
echo "libraries = flexiblas" >> site.cfg;
echo "[lapack]" >> site.cfg;
echo "libraries = flexiblas" >> site.cfg;
echo "[blas]" >> site.cfg;
echo "libraries = flexiblas" >> site.cfg;'
MODULE_BUILD_DEPS="arch/sse3 flexiblas/3.0.4"
PYTHON_DEPS="nose hypothesis"
PYTHON_DEPS_DEFAULT=""
MODULE_BUILD_DEPS_DEFAULT="cython/.0.29.36 pytest python-build-bundle"
PYTHON_TESTS="numpy.__config__.show(); numpy.test()"
