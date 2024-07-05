PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/asarnow/pyem/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS="
	sed -i -e 's/matplotlib-base/matplotlib/' -e \"s/version=.*/version='${VERSION}',/\" setup.py;
"
MODULE_RUNTIME_DEPS='arrow'
