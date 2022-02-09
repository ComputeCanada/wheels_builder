PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/matplotlib/basemap/archive/v${VERSION}.tar.gz"
PACKAGE_DOWNLOAD_NAME="v${VERSION}.tar.gz"
PACKAGE_FOLDER_NAME="basemap-${VERSION}"
MODULE_BUILD_DEPS="proj geos"
PYTHON_DEPS="numpy~=$NUMPY_DEFAULT_VERSION matplotlib pyproj pyshp python-dateutil"
PRE_DOWNLOAD_COMMANDS="export GEOS_DIR=${EBROOTGEOS} "
PYTHON_IMPORT_NAME="mpl_toolkits.basemap"

