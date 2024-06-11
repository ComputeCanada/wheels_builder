if [[ $EBVERSIONGENTOO -ge 2023 ]]; then
	GENERIC_ARCH=avx2
else
	GENERIC_ARCH=sse3
fi
MODULE_BUILD_DEPS="arch/$GENERIC_ARCH flexiblas"

# From 1.26, strictly use meson. Keep old instructions in case of, for now
if [[ $(translate_version $VERSION) -ge $(translate_version '1.26.0')  ]]; then
	PYTHON_DEPS=" pytest hypothesis -U pip>=24 meson-python setuptools"
	PIP_WHEEL_ARGS='
		-Csetup-args=-Dblas=flexiblas
		-Csetup-args=-Dlapack=flexiblas
		-Csetup-args=-Dblas-order=flexiblas
		-Csetup-args=-Dlapack-order=flexiblas
		-Csetup-args=-Dallow-noblas=false
	'
	# cython is not picked up in one test, and it fail. Install cython in the virtual env.
	PRE_TEST_COMMANDS="pip install --ignore-installed 'cython>3.0.0'"
	MODULE_BUILD_DEPS_DEFAULT="cython/.3.0.10 pytest python-build-bundle"
else
	# One could also set NPY_BLAS_LIBS, NPY_LAPACK_LIBS and NPY_CBLAS_LIBS since numpy 1.21.
	PRE_BUILD_COMMANDS='module load flexiblas;
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
fi

PYTHON_TESTS="numpy.__config__.show(); numpy.test()"
