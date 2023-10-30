# jaxlib is a pain to build

if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
    MODULE_RUNTIME_DEPS="cuda/12.2 cudnn/8.9"
else
    MODULE_RUNTIME_DEPS="cuda/11.8 cudnn/8.6"
fi

if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
        echo "Thanks Bazel..for nothing! Using the following to add jaxlib wheels:"
        echo ""
        echo "module load gcc ${MODULE_RUNTIME_DEPS}"
        echo "bash unmanylinuxize.sh --package jaxlib --add_path \$CUDA_HOME/lib64:\$EBROOTCUDNN/lib --version ${VERSION:-X.Y.Z} --find_links=https://storage.googleapis.com/jax-releases/jax_releases.html"
        module load gcc $MODULE_RUNTIME_DEPS
        bash unmanylinuxize.sh --package jaxlib --add_path $CUDA_HOME/lib64:$EBROOTCUDNN/lib --version ${VERSION:?version required} --find_links=https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
        exit 1;
fi
