MODULE_RUNTIME_DEPS="gcc/9.3.0 gdal/3.4.1"
PRE_BUILD_COMMANDS="sed -e 's/gdal/pygdal/' -i setup.py"
