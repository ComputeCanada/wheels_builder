# robinhood is now read-only so latest is fine. Use it for faster hashing
PRE_BUILD_COMMANDS='
	git clone https://github.com/martinus/robin-hood-hashing robinhood;
'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/scikit-tda/ripser.py/archive/refs/tags/v${VERSION:?version required}.tar.gz"
