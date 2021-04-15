PACKAGE="astropy"
PYTHON_IMPORT_NAME=$PACKAGE
PACKAGE_FOLDER_NAME=$PACKAGE
PYTHON_DEPS="cython numpy scipy networkx torch extension_helpers jinja2"
#TEST_COMMAND="python -c import astropy;astropy.test()"
PYTHON_TESTS="astropy.test()"
