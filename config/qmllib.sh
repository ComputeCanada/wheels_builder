MODULE_BUILD_DEPS="flexiblas"
PYTHON_DEPS='-U meson meson-python'
PRE_BUILD_COMMANDS="sed -i -e 's/-lblas/-lflexiblas/' -e 's/-llapack/-lflexiblas/' _compile.py"

PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/qmlcode/qmllib.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"

POST_BUILD_COMMANDS='PYVER=${EBVERSIONPYTHON::-2}; wheel tags --remove --abi-tag=cp${PYVER//.} --python-tag=cp${PYVER//.} --platform-tag=linux_x86_64 $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
