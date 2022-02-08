MODULE_BUILD_DEPS="arch/sse3 flexiblas/3.0.4"
PYTHON_DEPS_DEFAULT=""
PYTHON_DEPS="numpy~=$NUMPY_DEFAULT_VERSION pytest pybind11 cython pythran"
PYTHON_TESTS="scipy.__config__.show(); scipy.test()"
