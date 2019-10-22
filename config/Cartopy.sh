if [[ "$RSNT_ARCH" == "avx" ]]; then
	MODULE_BUILD_DEPS="gcc/5.4.0 proj/4.9.3 geos gdal"
else
	MODULE_BUILD_DEPS="proj/4.9.3 geos gdal"
fi
PYTHON_DEPS="Cython numpy shapely pyshp six Pillow pyepsg pykdtree scipy OWSLib"
PRE_BUILD_COMMANDS="pip freeze"

