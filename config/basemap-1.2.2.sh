PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/matplotlib/basemap/archive/v1.2.2rel.tar.gz"
PACKAGE_DOWNLOAD_NAME="v1.2.2rel.tar.gz"
PRE_BUILD_COMMANDS="sed -i 's/__version__ = \"1.2.1\"/__version__ = \"1.2.2\"/' setup.py && export GEOS_DIR=${EBROOTGEOS} "
PACKAGE_FOLDER_NAME="basemap-${VERSION}"
MODULE_BUILD_DEPS="proj geos"
PYTHON_DEPS="numpy matplotlib pyproj pyshp python-dateutil"
PRE_DOWNLOAD_COMMANDS="export GEOS_DIR=${EBROOTGEOS} "
PYTHON_IMPORT_NAME="mpl_toolkits.basemap"

