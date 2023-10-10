# One could also set NPY_BLAS_LIBS, NPY_LAPACK_LIBS and NPY_CBLAS_LIBS since numpy 1.21.
PRE_BUILD_COMMANDS="module load flexiblas/$FLEXIBLAS_VERSION;"'
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
MODULE_BUILD_DEPS="flexiblas/$FLEXIBLAS_VERSION"
if [[ $EBVERSIONGENTOO != 2023 ]]; then
	MODULE_BUILD_DEPS="arch/sse3 $MODULE_BUILD_DEPS"
fi
PYTHON_DEPS="nose hypothesis"
PYTHON_DEPS_DEFAULT=""
MODULE_BUILD_DEPS_DEFAULT="cython/.0.29.36 pytest python-build-bundle"
# old versions don't build with most recent python-build-bundle (recent setuptools)
if [[ ${VERSION} =~ 1.1.* || ${VERSION} =~ 1.2[0123].* ]]; then
	if [[ $EBVERSIONGENTOO == 2023 ]]; then
		PYTHON_DEPS="$PYTHON_DEPS setuptools==63.4.3"
	else
		MODULE_BUILD_DEPS_DEFAULT="cython/.0.29.36 pytest python-build-bundle/2023a"
	fi
fi
PYTHON_TESTS="numpy.__config__.show(); numpy.test()"
