PYTHON_DEPS="  pytest hypothesis wheel"
if [[ "$RSNT_ARCH" == "sse3" ]]; then
	PRE_BUILD_COMMANDS="export BLIS_ARCH='generic'"
elif [[ "$RSNT_ARCH" == "avx2" ]]; then
	PRE_BUILD_COMMANDS="export BLIS_ARCH='haswell'"
elif [[ "$RSNT_ARCH" == "avx512" ]]; then
	PRE_BUILD_COMMANDS="export BLIS_ARCH='skx'"
fi
