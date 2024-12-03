# Forced to use git, as pip download try to build to evaluate but the setup.py requires that a human create
# a site.cfg but the repo do not provide an empty one.
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/phonopy/phono3py"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
MODULE_BUILD_DEPS="gcc flexiblas"
MODULE_RUNTIME_DEPS="gcc"
PRE_BUILD_COMMANDS="
	export PHPHCALC_USE_MTBLAS=ON;
	export CMAKE_ARGS='-DCMAKE_C_FLAGS=-fPIC';
	export BUILD_WITHOUT_LAPACKE=ON;
	export USE_CONDA_PATH=OFF;
"
PYTHON_DEPS='nanobind scikit-build-core'
