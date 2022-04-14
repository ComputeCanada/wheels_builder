MODULE_RUNTIME_DEPS="gcc/9.3.0 geos/3.10.2 proj/9.0.0 gdal/3.4.1 scipy-stack/2022a"
PRE_BUILD_COMMANDS="sed -i \"s/name='Cartopy'/name='Cartopy', version='${VERSION}'/\" setup.py"
