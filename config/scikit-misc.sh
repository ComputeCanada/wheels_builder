# Must use the GH repo and not release as an hardcoded `tools` directory is searched for
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/has2k1/scikit-misc.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PYTHON_DEPS='meson meson-python ninja --ignore-installed'
PRE_BUILD_COMMANDS="sed -i -e 's/openblas/flexiblas/' meson.build"
MODULE_BUILD_DEPS='flexiblas'
