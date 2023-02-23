PACKAGE="astropy"
PYTHON_IMPORT_NAME=$PACKAGE
PACKAGE_FOLDER_NAME=$PACKAGE
PYTHON_DEPS="scipy networkx extension_helpers jinja2 pytest pytest-astropy"
#TEST_COMMAND="python -c import astropy;astropy.test()"
PYTHON_TESTS="astropy.test()"
