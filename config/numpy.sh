if [[ $EBVERSIONGENTOO -ge 2023 ]]; then
    GENERIC_ARCH=avx2
else
    GENERIC_ARCH=sse3
fi
MODULE_BUILD_DEPS="arch/$GENERIC_ARCH flexiblas"

# From 1.26, strictly use meson.
PYTHON_DEPS="pytest hypothesis -U pip==24.0.0 meson-python setuptools<=60.0"
PIP_WHEEL_ARGS='
    -Csetup-args=-Dblas=flexiblas
    -Csetup-args=-Dlapack=flexiblas
    -Csetup-args=-Dblas-order=flexiblas
    -Csetup-args=-Dlapack-order=flexiblas
    -Csetup-args=-Dallow-noblas=false
'
# cython is not picked up in one test, and it fail. Install cython in the virtual env.
PRE_TEST_COMMANDS="pip install --ignore-installed 'cython>3.0.0'"
MODULE_BUILD_DEPS_DEFAULT="cython/.3.0.11"

PYTHON_TESTS="numpy.__config__.show(); numpy.test()"
