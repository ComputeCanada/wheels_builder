if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	PRE_BUILD_COMMANDS="CPATH=$CPATH:$EBROOTGENTOO/include/OpenEXR:$EBROOTGENTOO/include/Imath "
else
	MODULE_BUILD_DEPS='openexr'
fi
PATCHES='OpenEXR-fix-lib.patch'
PYTHON_IMPORT_NAME="OpenEXR"
