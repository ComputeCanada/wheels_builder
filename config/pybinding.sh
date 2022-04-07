declare -A cpu_targets
gcc_targets=(
	["avx"]="corei7-avx"
	["avx2"]="core-avx2"
	["avx512"]="skylake-avx512"
	["sse3"]="nocona"
)
target=${gcc_targets[$RSNT_ARCH]}

PRE_BUILD_COMMANDS="sed -i -e 's/-march=native/-march=$target/' cppcore/CMakeLists.txt"
