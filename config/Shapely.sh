MODULE_RUNTIME_DEPS="geos"
PIP_WHEEL_ARGS='--config-settings=setup-args="-Dc_link_args=-L${GEOS_DIR}/lib -lgeos_c -lgeos -lstdc++ -Wl,-rpath,${GEOS_DIR}/lib"'
TEST_COMMAND='
python -c "import shapely; from shapely.geometry import Point; patch = Point(0.0, 0.0).buffer(10.0); print(patch, patch.area);"
'
