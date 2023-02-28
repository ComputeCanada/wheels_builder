# Since v2 the geos module is not needed
MODULE_RUNTIME_DEPS="geos"
PATCHES="Shapely-1.8.1.post1.patch" # Not needed for v2 upward
TEST_COMMAND='
python -c "import shapely; from shapely.geometry import Point; patch = Point(0.0, 0.0).buffer(10.0); print(patch, patch.area);"
'
