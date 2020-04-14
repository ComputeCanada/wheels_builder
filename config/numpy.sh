PRE_BUILD_COMMANDS='echo [mkl] > site.cfg; echo library_dirs = $MKLROOT/lib/intel64 >> site.cfg; echo include_dirs = $MKLROOT/include >> site.cfg; echo mkl_libs = mkl_rt >> site.cfg; echo lapack_libs = >> site.cfg'
MODULE_BUILD_DEPS="imkl/2019.5.281"
PYTHON_DEPS="nose pytest cython"
PYTHON_DEPS_DEFAULT=""
PYTHON_TESTS="numpy.__config__.show(); numpy.test()"

