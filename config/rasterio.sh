if [[ "$EBVERSIONGENTOO" -eq "2020" ]] ; then
    MODULE_BUILD_DEPS="gcc/9.3.0 gdal"
elif [[ "$EBVERSIONGENTOO" -eq "2023" ]] ; then
    MODULE_BUILD_DEPS="gcc/12.3 gdal/3.7.2"
else
    MODULE_BUILD_DEPS="gcc gdal"
fi

PYTHON_DEPS=" affine snuggs cligj click-plugins enum34"


