# pip download cannot be used as it tries to use meson build configuration with OpenBlas when trying to determine metadata, and fails.
# we cannot patch the source dist before downloading it, so avoid pip download
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/scipy/scipy.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"

MODULE_BUILD_DEPS="flexiblas cmake"
PYTHON_DEPS_DEFAULT=""
PYTHON_DEPS="pythran>=0.14.0 meson-python>=0.15.0 pooch hypothesis pytest-xdist Cython==3.0.11"
if [[ ${VERSION} =~ 1.10.* ]]; then
	PYTHON_DEPS="$PYTHON_DEPS numpy==1.19.5;python_version<'3.10' "
fi

# Test test_x0_equals_Mb fail on avx512 capable processor:
# https://github.com/scipy/scipy/issues/17075#issuecomment-1255594078
# https://github.com/scipy/scipy/issues/15533
PYTHON_TESTS="scipy.__config__.show(); scipy.test(parallel=${SLURM_CPUS_PER_TASK:-1})"
PRE_BUILD_COMMANDS="sed -i -e 's/openblas/flexiblas/' meson.build"
