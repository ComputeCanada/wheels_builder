MODULE_BUILD_DEPS="flexiblas libxc/6 qcint/6"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pyscf/pyscf/archive/refs/tags/v${VERSION:?version required}.zip"
# Trick build into avx2 or avx512 since we patch march=native flag.
PRE_BUILD_COMMANDS='
	export VERBOSE=1;
	export CMAKE_CONFIGURE_ARGS="-DBLA_VENDOR=Flexiblas -DBLAS_LIBRARIES=-lflexiblas -DBUILD_MARCH_NATIVE=1 -DBUILD_LIBCINT=0 -DBUILD_LIBXC=0 -DUSE_QCINT=1"
'
