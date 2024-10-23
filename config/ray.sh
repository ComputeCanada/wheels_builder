# Unfortunately, Ray developers have turned to use the evil Bazel, and is now impossible to build.

PATCH_WHEEL_COMMANDS="
    unzip -q -o \$ARCHNAME ray/train/_internal/storage.py;
    patch -p2 -i \$SCRIPT_DIR/patches/ray-fix_s3.patch
    zip \$ARCHNAME ray/train/_internal/storage.py;
"

if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
        echo "Thanks Bazel..for nothing! Using the following to add ray wheels:"
        echo ""
        echo "bash unmanylinuxize.sh --package ray --version ${VERSION:-X.Y.Z}"
        bash unmanylinuxize.sh --package ray --version ${VERSION:?version required}
        exit 1;
fi
