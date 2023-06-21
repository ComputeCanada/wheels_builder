PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/WISDEM/WISDEM.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PYTHON_DEPS='meson'
# No GUI option but it does require matplotlib
PRE_BUILD_COMMANDS='
	sed -i -e "s/dearpygui/matplotlib/" pyproject.toml;
	sed -i -e "/pytest/d" wisdem/landbosse/model/ManagementCost.py;
'
# The wheel is not universal
POST_BUILD_COMMANDS="PYVER=\${EBVERSIONPYTHON::-2}; mv \$WHEEL_NAME \${WHEEL_NAME/py3-none-any/cp\${PYVER//.}-cp\${PYVER//.}\$(python3-config --abiflags)-linux_x86_64} && WHEEL_NAME=\$(ls *.whl)"
PATCHES="WISDEM-nogui.patch"
