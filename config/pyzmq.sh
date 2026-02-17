PYTHON_DEPS='scikit_build_core'
PYTHON_IMPORT_NAME="zmq"
# This clean and force regeneration of cython source that are outdated
PRE_BUILD_COMMANDS="python setup.py clean --all"
MODULE_BUILD_DEPS='-python-build-bundle'

