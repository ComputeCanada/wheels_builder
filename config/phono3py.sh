# Forced to use git, as pip download try to build to evaluate but the setup.py requires that a human create
# a site.cfg but the repo do not provide an empty one.
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/phonopy/phono3py"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
MODULE_BUILD_DEPS="gcc imkl flexiblas hdf5"
MODULE_RUNTIME_DEPS="gcc hdf5"
PRE_BUILD_COMMANDS="sed -i -e 's/use_mkl_lapacke = False/use_mkl_lapacke = True/' -e '/\"-DPHONO3PY=on\",/a\"-DCMAKE_C_FLAGS=-fPIC\",' setup.py; echo -e '[phono3py]\nextra_compile_args = -fopenmp -fPIC' >> site.cfg"
