PACKAGE_DOWNLOAD_ARGUMENT="https://files.pythonhosted.org/packages/dd/5a/ad8d3ef9c13d5afcc1e44a77f11792ee717f6727b3320bddbc607e935e2a/box2d-py-2.3.5.tar.gz"
PYTHON_IMPORT_NAME='Box2D'
MODULE_BUILD_DEPS="swig"
# Designed to work from an EGG with relative path. Must build before in order for some files to be generated.
PRE_BUILD_COMMANDS='sed -i -e "s/from \.%s import/from %s import/" setup.py && python setup.py build'
