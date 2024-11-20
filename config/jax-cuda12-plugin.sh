MODULE_RUNTIME_DEPS="cuda cudnn/9.2 nccl/2.18"

RPATHS=(
    '$EBROOTCUDACORE/lib64'
    '$EBROOTCUDACORE/extras/CUPTI/lib64'
    '$EBROOTCUDNN/lib'
    '$EBROOTNCCL/lib'
)
RPATHS=${RPATHS[*]}

if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
        echo "Thanks Bazel..for nothing! Using the following to add wheels:"
        echo ""
        echo "module load gcc ${MODULE_RUNTIME_DEPS}"
        echo "bash unmanylinuxize.sh --package jax_cuda12_plugin --add_path \${RPATHS// /:} --version ${VERSION:-X.Y.Z}"
        module load gcc $MODULE_RUNTIME_DEPS
        bash unmanylinuxize.sh --package jax_cuda12_plugin --add_path ${RPATHS// /:} --version ${VERSION:?version required}
        exit 1;
fi
