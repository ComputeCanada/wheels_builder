MODULE_BUILD_DEPS="flexiblas libxc/5.1.3 qcint"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pyscf/pyscf/archive/refs/tags/v${VERSION:?version required}.zip"
PRE_BUILD_COMMANDS='export VERBOSE=1; export CMAKE_CONFIGURE_ARGS="-DBLA_VENDOR=Flexiblas -DBLAS_LIBRARIES=-lflexiblas -DBUILD_LIBCINT=0 -DBUILD_LIBXC=0" '
