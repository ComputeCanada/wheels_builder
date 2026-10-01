MODULE_BUILD_DEPS='cuda/13'
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/NVIDIA/cutile-python.git@v${VERSION:?version required}"
# Pre-configure the temporary build directory so that cuda is found correctly
# The second cmake configure adds other options.
_pyver="${EBVERSIONPYTHON%.*}"
_cpython_tag="${_pyver//./}"
PRE_BUILD_COMMANDS='
    cmake -B build/temp.linux-x86_64-cpython-$_cpython_tag -DALLOW_WARNINGS=ON -DCUDAToolkit_ROOT=$CUDA_HOME -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_BUILD_TYPE=Release;
    echo "$VERSION" > src/cuda/tile/VERSION;
'
