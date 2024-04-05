MODULE_BUILD_DEPS="fftw flexiblas"
PRE_BUILD_COMMANDS="
	export SETUPTOOLS_SCM_PRETEND_VERSION=${VERSION:?version required};
	sed -i -e \"s/setup = \['--default-library=static'\]/setup = \['--default-library=static', '-Dblas=flexiblas', '-Dlapack=flexiblas'\]/\" pyproject.toml;
	"
PYTHON_DEPS='jupyter-core setuptools_scm>=8 setuptools>=64 meson-python>=0.14'

# pip download cannot be used as it tries to use meson build configuration with OpenBlas when trying to determine metadata, and fails.
# we cannot patch the source dist before downloading it, so avoid pip download
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/SHTOOLS/SHTOOLS"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
