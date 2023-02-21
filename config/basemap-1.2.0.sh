PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/matplotlib/basemap/archive/v1.2.0rel.tar.gz"
PACKAGE_DOWNLOAD_NAME="v1.2.0rel.tar.gz"
PRE_BUILD_COMMANDS="sed -i \"s/__version__ = '1.1.0'/__version__ = '1.2.0'/\"  lib/mpl_toolkits/basemap/__init__.py"
PACKAGE_FOLDER_NAME="basemap-${VERSION}"
MODULE_BUILD_DEPS="proj geos"
PYTHON_DEPS=" matplotlib pyproj pyshp python-dateutil"
PRE_DOWNLOAD_COMMANDS="export GEOS_DIR=${EBROOTGEOS} "
PYTHON_IMPORT_NAME="mpl_toolkits.basemap"

