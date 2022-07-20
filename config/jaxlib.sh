# jaxlib is a pain to build

MODULE_RUNTIME_DEPS="cuda/11.4 cudnn"

if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
        echo "Thanks Bazel..for nothing! Using the following to add jaxlib wheels:"
        echo ""
        echo "module load gcc ${MODULE_RUNTIME_DEPS}"
        echo "bash unmanylinuxize.sh --package jaxlib --add_path \$CUDA_HOME/lib64:\$EBROOTCUDNN/lib --version ${VERSION:-X.Y.Z} --find_links=https://storage.googleapis.com/jax-releases/jax_releases.html"
        module load gcc $MODULE_RUNTIME_DEPS
        bash unmanylinuxize.sh --package jaxlib --add_path $CUDA_HOME/lib64:$EBROOTCUDNN/lib --version ${VERSION:?version required} --find_links=https://storage.googleapis.com/jax-releases/jax_releases.html
        exit 1;
fi
