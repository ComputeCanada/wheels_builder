if [[ "$RSNT_ARCH" == "avx" ]]; then
	MODULE_BUILD_DEPS="gcc/5.4.0 geos"
else
	MODULE_BUILD_DEPS="gcc geos"
fi
# need to patch geos.py to find libgeos_c.so based on the module that was loaded at build time
PRE_BUILD_COMMANDS='sed -i -e "s;os.path.join(sys.prefix, \"lib\", \"libgeos_c.so\"),;\"$EBROOTGEOS/lib/libgeos_c.so\",;g" $(find . -name "geos.py")'

