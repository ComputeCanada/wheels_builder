PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pybox2d/pybox2d/archive/refs/tags/${VERSION:?version required}.tar.gz"
PYTHON_IMPORT_NAME='Box2D'
MODULE_BUILD_DEPS="swig"
# Designed to work from an EGG with relative path. Must build before in order for some files to be generated.
PRE_BUILD_COMMANDS='sed -i -e "s/from \.%s import/from %s import/" setup.py && python setup.py build'
