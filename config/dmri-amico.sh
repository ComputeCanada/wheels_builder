# Must use Git as no site.cfg in root directory...
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PYTHON_IMPORT_NAME=$PACKAGE
PACKAGE_FOLDER_NAME=$PACKAGE
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/daducci/AMICO"
PACKAGE_DOWNLOAD_CMD="git clone --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"

MODULE_BUILD_DEPS="flexiblas"
PYTHON_DEPS='spams_cython cython>3.0.0'
# Very bad design, but trick AMICO into using FlexiBLAS since it is hardcoded for Openblas.
# This is a hack, but it works. The proper way would be to patch the setup.py file.
PRE_BUILD_COMMANDS='
echo "[openblas]" > site.cfg;
echo "library_dir = $EBROOTFLEXIBLAS/lib" >> site.cfg;
echo "include_dir = $EBROOTFLEXIBLAS/include/flexiblas" >> site.cfg;
echo "library = flexiblas" >> site.cfg;
'
PYTHON_IMPORT_NAME='amico'
