# the patch is only valid between 1.9.1 and <7.1
if [[ -n "$VERSION" ]] && [[ 10#$(translate_version $VERSION) -lt 10#$(translate_version '7.1.0')  ]]; then
    PATCHES='pbr-fix_localversion.patch'

    PATCH_WHEEL_COMMANDS="
        unzip -q -o \$ARCHNAME pbr/version.py;
        patch -p1 pbr/version.py < \$SCRIPT_DIR/patches/pbr-fix_localversion.patch;
        zip -u \$ARCHNAME pbr/version.py;
    "
fi
