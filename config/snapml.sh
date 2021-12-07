PATCH_WHEEL_COMMANDS="unzip -o \$ARCHNAME && patch --verbose -p1 < \$SCRIPT_DIR/patches/snapml_fix_mpi.patch && zip -r \$ARCHNAME -r snapml"
