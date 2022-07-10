MODULE_RUNTIME_DEPS="gcc/9.3.0 gdal/3.4.3 cfitsio/3.48 postgresql/12.4"
POST_BUILD_COMMANDS='setrpaths.sh --path $WHEEL_NAME --add_path $EBROOTCFITSIO/lib:$EBROOTPOSTGRESQL/lib --any_interpreter '
