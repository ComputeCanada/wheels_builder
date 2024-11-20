MODULE_RUNTIME_DEPS="cuda tensorrt/8.6 cudnn/9.2 nccl/2.18"

RPATHS=(
    '$EBROOTCUDACORE/lib64'
    '$EBROOTCUDACORE/extras/CUPTI/lib64'
    '$EBROOTCUDNN/lib'
    '$EBROOTNCCL/lib'
    '$EBROOTTENSORRT/lib'
)
RPATHS=${RPATHS[*]}

PATCH_WHEEL_COMMANDS="
    unzip -q -o \$ARCHNAME jax_plugins/xla_cuda12/__init__.py;
    sed -i -e '1i import os; os.environ[\"XLA_FLAGS\"]=\"--xla_gpu_cuda_data_dir=$EBROOTCUDACORE \" + os.environ.get(\"XLA_FLAGS\",\"\")' jax_plugins/xla_cuda12/__init__.py;
    zip \$ARCHNAME jax_plugins/xla_cuda12/__init__.py;
"

if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
        echo "Thanks Bazel..for nothing! Using the following to add wheels:"
        echo ""
        echo "module -q load gcc ${MODULE_RUNTIME_DEPS}"
        echo "bash unmanylinuxize.sh --package jax_cuda12_pjrt --add_path \${RPATHS// /:} --version ${VERSION:-X.Y.Z}"
        module -q load  gcc $MODULE_RUNTIME_DEPS
        bash unmanylinuxize.sh --package jax_cuda12_pjrt --add_path ${RPATHS// /:} --version ${VERSION:?version required}
        exit 1;
fi
