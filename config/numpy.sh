PRE_BUILD_COMMANDS='module load flexiblascore/.3.0.4; echo "[DEFAULT]" > site.cfg; echo "library_dirs = $EBROOTFLEXIBLASCORE/lib" >> site.cfg; echo "include_dirs = $EBROOTFLEXIBLASCORE/include/flexiblas" >> site.cfg; echo "[atlas]" >> site.cfg; echo "atlas_libs = flexiblas" >> site.cfg; echo "[lapack]" >> site.cfg; echo "lapack_libs = flexiblas" >> site.cfg'
if [[ -z $EBROOTGENTOO ]]; then
	MODULE_BUILD_DEPS="imkl/2019.2.187"
else
	MODULE_BUILD_DEPS="flexiblascore/.3.0.4"
fi
PYTHON_DEPS="nose pytest cython hypothesis"
PYTHON_DEPS_DEFAULT=""
PYTHON_TESTS="numpy.__config__.show(); numpy.test()"

