MODULE_BUILD_DEPS="gcc geos"
# need to patch geos.py to find libgeos_c.so based on the module that was loaded at build time
PRE_BUILD_COMMANDS='sed -i -e "s;path.join([^)]*libgeos_c.so[^)]*);path.join(os.getenv(\"EBROOTGEOS\"), \"lib\", \"libgeos_c.so\");g" -e "s/CONDA_PREFIX/EBROOTGEOS/g" $(find . -name "geos.py")'
