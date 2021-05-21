# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!! PLEASE READ build_2.5_README.md !!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

set -e  # Stop on error, like a serious programming language

: ${BAZEL_BIN_PATH:?Variable not set or empty}  # BAZEL_BIN_PATH must contain the bazel executable (managed by bazelisk)
: ${TF_SOURCE_PATH:?Variable not set or empty}

orig_working_dir=$(pwd)

cd $TF_SOURCE_PATH

if [ "$DO_CONFIGURE" != 1 ]; then
    # We will skip the configure step by creating `.tf_configure.bazelrc` and `tools/python_bin_path.sh` (this second file is created later)
    this_script_parent_dir=$(dirname "$(readlink -f "$0")")
    configure_file=$this_script_parent_dir/tf_2.5_configure.bazelrc
    cp $configure_file .tf_configure.bazelrc
fi

PATCHELF_BIN_PATH=/home/lemc2220/bin/patchelf  # Use the patched patchelf built by Bart Oldeman, this dir contains the executable

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

    if [ -f .tf_configure.bazelrc ]; then
        # .tf_configure.bazelrc exists, either if configure done by you, or created above by this script

        # Replace the dummy string VENV_PATH if present
        env_path=$(realpath env-build)
        sed -i "s|VENV_PATH|$env_path|" .tf_configure.bazelrc

        # Make sure the python version is correct in the file
        sed -i -r "s/python3\.[0-9]+/python${PYTHON_VERSION}/" .tf_configure.bazelrc

        # Create `tools/python_bin_path.sh` from `.tf_configure.bazelrc`
        grep PYTHON_BIN_PATH .tf_configure.bazelrc | sed -e 's/build --action_env/export/' > tools/python_bin_path.sh
    else
        # run configure step to make `.tf_configure.bazelrc` and `tools/python_bin_path.sh`

        ./configure
        echo 'build --action_env GCC_HOST_COMPILER_PREFIX="/cvmfs/soft.computecanada.ca/gentoo/2020/usr/bin"' >> .tf_configure.bazelrc
    fi

    bazel clean
    bazel build --config=cuda //tensorflow/tools/pip_package:build_pip_package
    ./bazel-bin/tensorflow/tools/pip_package/build_pip_package $wheels_out_path/$PYTHON_VERSION
    setrpaths.sh --path $wheels_out_path/$PYTHON_VERSION/tensorflow*.whl --add_path /cvmfs/soft.computecanada.ca/easybuild/software/2020/Core/cudacore/11.0.2/lib64:/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/cudnn/8.0.3/lib64:/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/nccl/2.7.8/lib64 --any_interpreter --add_origin
    mv $wheels_out_path/$PYTHON_VERSION/tensorflow*.whl $orig_working_dir

    deactivate
done

cd $orig_working_dir
