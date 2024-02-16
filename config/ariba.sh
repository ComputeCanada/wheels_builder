PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/sanger-pathogens/ariba/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS="sed -i -e \"s/version=.*/version='$VERSION',/\" setup.py"
