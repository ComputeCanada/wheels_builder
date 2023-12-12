MODULE_BUILD_DEPS="glm/0.9.9.8 netcdf/4.9.0 glew/2.1.0"
PRE_BUILD_COMMANDS="sed -i "s@/usr@$EBROOTGENTOO@" setup.py"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/schrodinger/pymol-open-source/archive/refs/tags/v${VERSION:?version required}.tar.gz"
