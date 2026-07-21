POST_BUILD_COMMANDS="
$SCRIPT_DIR/manipulate_wheels.py --inplace --force --remove_req \
    'nvidia-cuda-runtime-cu12; extra == \"cu12\"' \
    'nvidia-cuda-cccl-cu12; extra == \"cu12\"' \
    'nvidia-cuda-nvcc-cu12; extra == \"cu12\"' \
    'nvidia-cuda-nvrtc-cu12; extra == \"cu12\"' \
    'nvidia-cuda-runtime; extra == \"cu13\"' \
    'nvidia-cuda-cccl; extra == \"cu13\"' \
    'nvidia-cuda-nvcc; extra == \"cu13\"' \
    'nvidia-cuda-nvrtc; extra == \"cu13\"' \
    -w \$WHEEL_NAME
"
