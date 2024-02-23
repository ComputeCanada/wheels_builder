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

if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
        module load gcc $MODULE_RUNTIME_DEPS
        bash unmanylinuxize.sh --package tensorflow --add_path ${RPATHS// /:} --version ${VERSION:?version required}
        exit 0;
fi
