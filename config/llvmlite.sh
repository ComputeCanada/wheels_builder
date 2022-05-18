
if [[ -z "$EBROOTGENTOO" ]]; then
  PYTHON_DEPS="enum34"
  MODULE_BUILD_DEPS="llvm cuda/10.1 tbb"
else
  if [[ "$VERSION" == "0.32.1" ]]; then
    MODULE_BUILD_DEPS="llvm/8 cuda/11.0 tbb"
  else
    MODULE_BUILD_DEPS="llvm/11 cuda/11.4 tbb"
  fi
fi
PATCHES="llvmlite-0.28.0-fpic.patch"

