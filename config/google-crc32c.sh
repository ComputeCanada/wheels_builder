PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/googleapis/python-crc32c.git@v${VERSION:?version required}"
# Must prebuild the underlying library. Build a static one to be embeded.
PRE_BUILD_COMMANDS='
	cd google_crc32c/ &&
	export CRC32C_INSTALL_PREFIX=$PWD/INST &&
	cmake --fresh -B _build -DCMAKE_BUILD_TYPE=Release -DCRC32C_BUILD_TESTS=OFF -DCRC32C_BUILD_BENCHMARKS=OFF -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=${CRC32C_INSTALL_PREFIX} -DCMAKE_POSITION_INDEPENDENT_CODE=ON &&
	cmake --build _build/ &&
	cmake --install _build/ &&
	cd .. &&
	export LDFLAGS="-lstdc++" &&
	python setup.py build_ext --include-dirs=$CRC32C_INSTALL_PREFIX/include/ --library-dirs=$CRC32C_INSTALL_PREFIX/lib64/;
'
