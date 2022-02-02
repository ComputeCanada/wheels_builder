if [[ "$VERSION" == "1.2.2" ]]; then
    # Need to make sure that we only use packages that are compatible with numpy 1.19.x
    # The best (only) way I could find, was loading this module, as it already contains
    # many of the dependencies that were all built against numpy 1.19.2.
    MODULE_RUNTIME_DEPS="scipy-stack/2020b"
fi
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/obspy/obspy/archive/refs/tags/${VERSION}.tar.gz"
PACKAGE_DOWNLOAD_CMD="wget -O ${PACKAGE_DOWNLOAD_NAME} ${PACKAGE_DOWNLOAD_ARGUMENT}"
PRE_BUILD_COMMANDS="sed -i \"s/version=get_git_version..,/version='${VERSION}',/\" setup.py"

