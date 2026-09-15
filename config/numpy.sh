if [[ $EBVERSIONGENTOO -ge 2023 ]]; then
    GENERIC_ARCH=avx2
else
    GENERIC_ARCH=sse3
fi
MODULE_BUILD_DEPS="arch/$GENERIC_ARCH flexiblas"

# From 1.26, strictly use meson.
PYTHON_DEPS="pytest hypothesis==6.155.7 meson-python setuptools pytest-timeout"
PIP_WHEEL_ARGS='
    -Csetup-args=-Dblas=flexiblas
    -Csetup-args=-Dlapack=flexiblas
    -Csetup-args=-Dblas-order=flexiblas
    -Csetup-args=-Dlapack-order=flexiblas
    -Csetup-args=-Dallow-noblas=false
    -Csetup-args=-Denable-openmp=true
'
# cython is not picked up in one test, and it fail. Install cython in the virtual env.
PRE_TEST_COMMANDS="pip install --ignore-installed 'cython>3.0.0'"
if [[ $EBVERSIONGENTOO == 2026 ]]; then
    MODULE_BUILD_DEPS_DEFAULT="cython/.3.3.0"
elif [[ $EBVERSIONGENTOO == 2023 ]]; then
    MODULE_BUILD_DEPS_DEFAULT="cython/.3.2.4"
fi
PRE_TEST_COMMANDS='ulimit -s 8192'
# test_xerbla_override spinlock under StdEnv/2026. `np.linalg.lapack_lite` is now deprecated.
PYTHON_TESTS="numpy.__config__.show(); numpy.test(extra_argv=['--timeout=30', '--timeout-method=signal'])"
