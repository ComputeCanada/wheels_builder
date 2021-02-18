PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/phonopy/phono3py/archive/v$VERSION.tar.gz"
MODULE_BUILD_DEPS="intel imkl hdf5"
MODULE_RUNTIME_DEPS="hdf5"
PATCHES="phono3py-1.22.0-mkl.patch"

export CC="icc"
