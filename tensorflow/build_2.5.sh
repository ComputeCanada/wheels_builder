# Reqs:
#  Install Bazel (with bazelisk)
#  Checkout tensorflow source, cd in repo

set -e  # Stop on error, like a serious programming language

export PATH=/home/lemc2220/source:$PATH  # Add the bazel executable path
export PATH=/home/lemc2220/bin:$PATH  # Use the patched patchelf built by Bart Oldeman

if [ -d /tmp/tensorflow_pkg ]; then
    echo "Please rm -rf /tmp/tensorflow_pkg before proceeding."
    exit 1
fi 

module load gcc/9.3 cuda/11.0 cudnn/8 nccl/2.7

for PYTHON_VERSION in 3.6 3.7 3.8;
do
    module load python/$PYTHON_VERSION

    rm -rf env-build
    virtualenv env-build
    source env-build/bin/activate
    pip install --upgrade pip
    pip install numpy==1.19.2 wheel
    pip install keras_preprocessing --no-deps

    if [ ! -f .tf_configure.bazelrc ]; then
        ./configure
        echo 'build --action_env GCC_HOST_COMPILER_PREFIX="/cvmfs/soft.computecanada.ca/gentoo/2020/usr/bin"' >> .tf_configure.bazelrc
    fi

    sed -i -r "s/python3\.[0-9]/python${PYTHON_VERSION}/" .tf_configure.bazelrc

    bazel clean
    bazel build --config=cuda //tensorflow/tools/pip_package:build_pip_package
    ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
    setrpaths.sh --path /tmp/tensorflow_pkg/tensorflow*.whl --add_path /cvmfs/soft.computecanada.ca/easybuild/software/2020/Core/cudacore/11.0.2/lib64:/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/cudnn/8.0.3/lib64:/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/nccl/2.7.8/lib64 --any_interpreter --add_origin
    mkdir /tmp/tensorflow_pkg/$PYTHON_VERSION
    mv /tmp/tensorflow_pkg/tensorflow*.whl /tmp/tensorflow_pkg/$PYTHON_VERSION

    deactivate
done

