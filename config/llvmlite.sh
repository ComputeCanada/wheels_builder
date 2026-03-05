if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
    MODULE_BUILD_DEPS="llvm/20"
    PYTHON_DEPS='setuptools<80'
else
    MODULE_BUILD_DEPS="llvm/14 cuda/11.4 tbb"
    PATCHES="llvmlite-0.28.0-fpic.patch"
fi
