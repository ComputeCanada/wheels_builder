# TF comes from upstream

if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
    MODULE_RUNTIME_DEPS="cuda/12 cudnn/8.9 tensorrt"
else
    MODULE_RUNTIME_DEPS="gcc cuda/11.7 cudnn/8.6 tensorrt"
fi

RPATHS=(
    '$EBROOTCUDACORE/lib64'
    '$EBROOTCUDACORE/extras/CUPTI/lib64'
    '$EBROOTCUDNN/lib'
    '$EBROOTTENSORRT/lib'
)
RPATHS=${RPATHS[*]}

# Force define XLA_FLAGS for XLA JIT compilation. Define cuda path used
PATCH_WHEEL_COMMANDS="
    unzip -o \$ARCHNAME tensorflow/__init__.py;
    patch -N -p0 < $SCRIPT_DIR/patches/tensorflow_xla_flags_cuda.patch;
    sed -i -e 's;@@CUDA_HOME@@;$EBROOTCUDACORE;' tensorflow/__init__.py;
    zip \$ARCHNAME tensorflow/__init__.py;
"

if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
        module load gcc $MODULE_RUNTIME_DEPS
        bash unmanylinuxize.sh --package tensorflow --add_path ${RPATHS// /:} --version ${VERSION:?version required}
        exit 0;
fi
