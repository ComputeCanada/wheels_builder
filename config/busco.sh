PACKAGE_DOWNLOAD_ARGUMENT="https://gitlab.com/ezlab/busco.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone $PACKAGE_DOWNLOAD_ARGUMENT --branch ${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS="sed -i -e \"/setup(/a install_requires=['numpy','pandas','biopython'],\" setup.py;"
PYTHON_IMPORT_NAME='busco.run_BUSCO'
