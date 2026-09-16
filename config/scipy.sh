# pip download cannot be used as it tries to use meson build configuration with OpenBlas when trying to determine metadata, and fails.
# we cannot patch the source dist before downloading it, so avoid pip download
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/scipy/scipy.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"

MODULE_BUILD_DEPS="flexiblas cmake"
PYTHON_DEPS_DEFAULT=""
PYTHON_DEPS="pythran>=0.14.0 meson>=1.5.0 meson-python>=0.15.0 pooch hypothesis pytest-xdist Cython>=3.0.11 pybind11>=2.13.2 pytest-timeout cffi"
if [[ ${VERSION} =~ 1.10.* ]]; then
	PYTHON_DEPS="$PYTHON_DEPS numpy==1.19.5;python_version<'3.10' "
fi
# test test_nan_values hangs,
# test_all_data_read_bad_checksum and test_all_data_read_overlap are not correctly support on 3.14, see https://github.com/scipy/scipy/issues/23185
PYTHON_TESTS="scipy.__config__.show(); scipy.test(parallel=1, extra_argv=['--timeout=180', '--timeout-method=signal', '-k', 'not test_all_data_read_bad_checksum and not test_all_data_read_overlap'])"
PRE_BUILD_COMMANDS="sed -i -e 's/openblas/flexiblas/' meson.build"
