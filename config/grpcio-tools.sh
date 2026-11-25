PYTHON_IMPORT_NAME='grpc_tools'
PRE_BUILD_COMMANDS="sed -i 's|#include <bmi2intrin.h>|#include <immintrin.h>|' third_party/abseil-cpp/absl/container/internal/raw_hash_set.h"
