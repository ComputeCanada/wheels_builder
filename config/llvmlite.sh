
if [[ -z "$EBROOTGENTOO" ]]; then
  PYTHON_DEPS="enum34"
  MODULE_BUILD_DEPS="llvm cuda/10.1 tbb"
else
  #PYTHON_DEPS="enum34"
  MODULE_BUILD_DEPS="llvm cuda/11.0 tbb"
  if [[ "$VERSION" == "0.32.1" ]]; then
	  MODULE_BUILD_DEPS="llvm/8 cuda/11.0 tbb"
  fi
fi
PATCHES="llvmlite-0.28.0-fpic.patch"

