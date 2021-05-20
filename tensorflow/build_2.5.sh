# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!! PLEASE READ build_2.5_README.md !!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

set -e  # Stop on error, like a serious programming language

: ${BAZEL_BIN_PATH:?Variable not set or empty}  # BAZEL_BIN_PATH must contain the bazel executable (managed by bazelisk)

PATCHELF_BIN_PATH=/home/lemc2220/bin  # Use the patched patchelf built by Bart Oldeman

export PATH=$BAZEL_BIN_PATH:$PATCHELF_BIN_PATH:$PATH

wheels_out_path=/tmp/$USER/tensorflow_pkg

if [ -d $wheels_out_path ]; then
    echo "Please rm -rf $wheels_out_path before proceeding."
    exit 1
else
    mkdir -p $wheels_out_path
fi 

module load gcc/9.3 cuda/11.0 cudnn/8 nccl/2.7

for PYTHON_VERSION in 3.6 3.7 3.8;
do
    mkdir $wheels_out_path/$PYTHON_VERSION
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

    sed -i -r "s/python3\.[0-9]+/python${PYTHON_VERSION}/" .tf_configure.bazelrc

    bazel clean
    bazel build --config=cuda //tensorflow/tools/pip_package:build_pip_package
    ./bazel-bin/tensorflow/tools/pip_package/build_pip_package $wheels_out_path/$PYTHON_VERSION
    setrpaths.sh --path $wheels_out_path/$PYTHON_VERSION/tensorflow*.whl --add_path /cvmfs/soft.computecanada.ca/easybuild/software/2020/Core/cudacore/11.0.2/lib64:/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/cudnn/8.0.3/lib64:/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/nccl/2.7.8/lib64 --any_interpreter --add_origin

    deactivate
done

