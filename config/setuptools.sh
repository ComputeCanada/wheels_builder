PATCHES='setuptools-fix_trove_classifiers_hassle.patch'

if [[ $THIS_SCRIPT == 'unmanylinuxize.sh' ]]; then
	PATCH_WHEEL_COMMANDS="
    unzip -q -o \$ARCHNAME setuptools/config/_validate_pyproject/formats.py;
    patch -p 1 -i $SCRIPT_DIR/patches/$PATCHES;
    zip \$ARCHNAME setuptools/config/_validate_pyproject/formats.py;
	"
fi
