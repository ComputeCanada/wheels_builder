MODULE_RUNTIME_DEPS="gcc gdal cfitsio/3.48 postgresql"
POST_BUILD_COMMANDS='setrpaths.sh --path $WHEEL_NAME --add_path $EBROOTCFITSIO/lib:$EBROOTPOSTGRESQL/lib --any_interpreter '
