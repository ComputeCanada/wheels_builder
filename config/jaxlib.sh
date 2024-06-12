# jaxlib is a pain to build

if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
    MODULE_RUNTIME_DEPS="cuda/12.2 cudnn/8.9 nccl/2.18"
else
    MODULE_RUNTIME_DEPS="cuda/11.8 cudnn/8.6"
fi

RPATHS=(
    '$EBROOTCUDACORE/lib64'
    '$EBROOTCUDACORE/extras/CUPTI/lib64'
    '$EBROOTCUDNN/lib'
    '$EBROOTNCCL/lib'
)
RPATHS=${RPATHS[*]}

PATCH_WHEEL_COMMANDS="
    unzip -q -o \$ARCHNAME jaxlib/__init__.py;
    sed -i -e '15 a import os; os.environ[\"XLA_FLAGS\"]=\"--xla_gpu_cuda_data_dir=$EBROOTCUDACORE \" + os.environ.get(\"XLA_FLAGS\",\"\")' jaxlib/__init__.py;
    zip \$ARCHNAME jaxlib/__init__.py;
"

if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
        echo "Thanks Bazel..for nothing! Using the following to add jaxlib wheels:"
        echo ""
        echo "module load gcc ${MODULE_RUNTIME_DEPS}"
        echo "bash unmanylinuxize.sh --package jaxlib --add_path \${RPATHS// /:} --version ${VERSION:-X.Y.Z} --find_links=https://storage.googleapis.com/jax-releases/jax_releases.html"
        module load gcc $MODULE_RUNTIME_DEPS
        bash unmanylinuxize.sh --package jaxlib --add_path ${RPATHS// /:} --version ${VERSION:?version required} --find_links=https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
        exit 1;
fi
