# jaxlib is a pain to build, now cpu only

if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
    echo "Thanks Bazel..for nothing! Using the following to add jaxlib wheels:"

    echo ""
    echo "module load gcc"
    echo "bash unmanylinuxize.sh --package jaxlib --version ${VERSION:-X.Y.Z}"
    bash unmanylinuxize.sh --package jaxlib --version ${VERSION:?version required}
fi
