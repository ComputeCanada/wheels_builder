#!/bin/bash
# Useful stack overflow thread
# https://stackoverflow.com/questions/37761469/how-to-add-external-header-files-during-bazel-tensorflow-build
# https://stackoverflow.com/questions/43921911/how-to-resolve-bazel-undeclared-inclusions-error
# Successful build with VERBS, GDR and MPI : /dev/shm/fafor10/tf_1511368394/tensorflow
set -e

function usage() {
    echo "Usage:"
    echo "Load a python module then, call"
    echo "$0 -v <version_tag> -a <architecture>"
}

if ! module -t list | grep -q python; then
   usage
   exit
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMP=$(getopt -o a:v: --longoptions version:,arch:,gpu,debug -n $0 -- "$@")
eval set -- "$TEMP"
ARG_VERSION=
ARG_ARCH=
ARG_GPU=0
export ARG_DEBUG=0

while true; do
    case "$1" in
        -v|--version)
            case "$2" in
                "") ARG_VERSION=""; shift 2 ;;
                *) ARG_VERSION=$2; shift 2 ;;
            esac;;
        --gpu)
            ARG_GPU=1; shift ;;
        -a|--arch)
            case "$2" in
                "") ARG_ARCH=""; shift 2 ;;
                *) ARG_ARCH=$2; shift 2 ;;
            esac;;
        --debug)
            ARG_DEBUG=1; shift ;;
        --) shift; break ;;
        *) echo "Unknown parameter $1"; usage; exit 1 ;;
    esac
done

if [[ -z "$ARG_VERSION" ]]; then
    usage; exit 1
fi

if [[ $ARG_ARCH == 'avx512' ]]; then
    export CC_OPT_FLAGS="-march=skylake-avx512 -O2"
elif [[ $ARG_ARCH == "avx2" ]]; then
    export CC_OPT_FLAGS="-march=core-avx2 -O2"
elif [[ $ARG_ARCH == "avx" ]]; then
    export CC_OPT_FLAGS="-march=corei7-avx -O2"
elif [[ $ARG_ARCH == "sse3" ]]; then
    export CC_OPT_FLAGS="-march=nocona -mtune=generic -O2"
else
   usage; exit 1
fi

module load gcc/7.3.0 java bazel/0.19.2 imkl
if [[ $ARG_GPU == 1 ]]; then
    module load cuda/10.0.130 cudnn/7.4 openmpi/2.1.1
fi

unset CPLUS_INCLUDE_PATH
unset C_INCLUDE_PATH

OPWD=$(pwd)
export TF_COMPILE_PATH=/dev/shm/${USER}/tf_$(date +'%s')
export TMPDIR=$TF_COMPILE_PATH
export TMP=$TMPDIR
export BAZEL_ROOT_PATH=$TF_COMPILE_PATH/bazel
mkdir -p $TF_COMPILE_PATH; cd $TF_COMPILE_PATH

if [[ $ARG_DEBUG == 1 ]]; then
    echo "Debug mode - compilation results will be in: $TF_COMPILE_PATH"
fi

#git clone https://github.com/tensorflow/tensorflow.git;
tar xf /home/fafor10/tensorflow.tar.gz
cd tensorflow
git pull
git checkout $ARG_VERSION
git cherry-pick -n 03e63a291bc95dacaa821585f39a360b43465cb5

GCC_PREFIX=$(dirname $(dirname $(which gcc)))
if [[ $ARG_GPU == 1 ]]; then
    CROSSTOOL_FILE=third_party/gpus/crosstool/CROSSTOOL.tpl
    RPATH_TO_ADD="$EBROOTCUDNN/lib64 $(find $EBROOTCUDA -name lib64) $EBROOTIMKL/compilers_and_libraries/linux/lib/intel64_lin"
    for path in $RPATH_TO_ADD; do
        sed -i "\;flag: \"-Wl,-no-as-needed\"; a \ \ \ \ \ \ \ \ flag: \"-Wl,-rpath=$path\"" $CROSSTOOL_FILE
    done

    sed -i "s;-B/usr/bin;-B$EBROOTGCC/bin;g" third_party/gpus/cuda_configure.bzl
    sed -i "\;%{linker_bin_path_flag}; a \ \ \ \ \ \ \ \ flag: \"-B$EBROOTGCC/lib/\"" $CROSSTOOL_FILE

    sed -i "\;linking_mode_flags { mode: DYNAMIC }; a \
\ \ cxx_builtin_include_directory: \"/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/gcc-7.3.0/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include/\"" $CROSSTOOL_FILE
    sed -i "\;linking_mode_flags { mode: DYNAMIC }; a \
\ \ cxx_builtin_include_directory: \"/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/gcc-7.3.0/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include-fixed/\"" $CROSSTOOL_FILE

    # look for tools
    for tool in $(grep 'tool_path { .* }' $CROSSTOOL_FILE | grep -Po '(?<=path: ")([a-z\/]{1,})'); do
	    toolname=$(basename $tool)
	    new_path=$(which $toolname)
	    sed -i "s;$tool;$new_path;g" $CROSSTOOL_FILE
    done
fi

#sed -i -r "/libiomp5/d" third_party/mkl/mkl.BUILD
sed -i -r "s/\"include\/\*\"/\"include\/\*.h\"/g" third_party/mkl/mkl.BUILD
sed -i -r "s;bazel (clean|fetch|query); bazel --output_user_root=$BAZEL_ROOT_PATH \1;g" configure
sed -i -r "s;^_VERSION = '(.+)'$;_VERSION = '\1+computecanada';g" tensorflow/tools/pip_package/setup.py

# setup our own project_name
if [[ $ARG_GPU == 1 ]]; then
    PKG_NAME="tensorflow_gpu"
else
    PKG_NAME="tensorflow_cpu"
fi

sed -i "s;setup.py bdist_wheel .* >/dev/null;setup.py bdist_wheel --project_name $PKG_NAME > /dev/null;g" tensorflow/tools/pip_package/build_pip_package.sh

virtualenv buildenv
source buildenv/bin/activate
pip install numpy wheel enum34 mock
pip install keras_applications keras_preprocessing

# Download MKL-ML and patch it
sed -n -e 's;"\(https://github.com/intel/mkl-dnn/.*lnx.*\.tgz\)";\1;p' tensorflow/workspace.bzl | tr ',' ' ' | xargs wget -O $TF_COMPILE_PATH/mklml_lnx.tgz
mkdir $TF_COMPILE_PATH/mklml_lnx
tar xf $TF_COMPILE_PATH/mklml_lnx.tgz -C $TF_COMPILE_PATH/mklml_lnx --strip-components 1
#rm $TF_COMPILE_PATH/mklml_lnx/lib/libiomp5.so
setrpaths.sh --path $TF_COMPILE_PATH/mklml_lnx/lib --add_path $EBROOTIMKL/compilers_and_libraries/linux/lib/intel64_lin

if [[ $ARG_GPU == 1 ]]; then
    # CC MPI is not compiled with C++ API
    export CC_OPT_FLAGS="$CC_OPT_FLAGS -DOMPI_SKIP_MPICXX=1 "

    # Setup third party library from Nix files
    mkdir -p third_party/rdma/include
    ln -s $NIXUSER_PROFILE/include/rdma third_party/rdma/include/ 
    ln -s $NIXUSER_PROFILE/include/infiniband third_party/rdma/include/

    cat >> third_party/rdma/BUILD << EOF
package(default_visibility = ["//visibility:public"])

licenses(["notice"])

cc_library(
    name = "rdma",
    hdrs = glob(["include/rdma/*.h", "include/infiniband/*.h"]),
    includes = [".", "include"]
)
EOF
    # Add dependency to third_party library
    git apply $SCRIPT_DIR/rdma.patch
    # TF 1.11.0 ISSUE 21999
    #git cherry-pick -n c67ded664a20f27b4e90020bf76a097b462182b1
    #git apply $SCRIPT_DIR/tensorflow-mpi.patch

    export \
    TF_NEED_CUDA=1 \
    TF_CUDA_VERSION=$(echo $EBVERSIONCUDA | grep -Po '\d{1,}.\d{1,}(?=.\d{1,})') \
    CUDA_TOOLKIT_PATH=$CUDA_HOME \
    TF_CUDNN_VERSION=$(echo $EBVERSIONCUDNN | grep -Po '\d{1,}(?=.\d{1,})') \
    CUDNN_INSTALL_PATH="$EBROOTCUDNN" \
    TF_CUDA_CLANG=0 \
    TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7,5.2,6.0,6.1" \
    TF_NEED_MPI=1 \
    TF_NEED_GDR=1 \
    TF_NEED_VERBS=1 \
    GCC_HOST_COMPILER_PATH=$(which mpicc) \
    TF_NCCL_VERSION="1.3" \
    MPI_HOME="$EBROOTOPENMPI"
    CONFIG_XOPT="--config cuda"
else
    export \
    TF_NEED_CUDA=0 \
    TF_NEED_MPI=0 \
    TF_NEED_GDR=0 \
    TF_NEED_VERBS=0 \
    GCC_HOST_COMPILER_PATH=$(which gcc) #\
#    CONFIG_XOPT="--cxxopt=-Wl,-rpath,$EBROOTIMKL/compilers_and_libraries/linux/lib/intel64_lin"
fi

export \
PYTHON_BIN_PATH=$(which python) \
USE_DEFAULT_PYTHON_LIB_PATH=1 \
TF_NEED_AWS=0 \
TF_NEED_NGRAPH=0 \
TF_NEED_S3=0 \
TF_NEED_GCP=0 \
TF_NEED_HDFS=0 \
TF_NEED_OPENCL=0 \
TF_NEED_OPENCL_SYCL=0 \
TF_NEED_JEMALLOC=1 \
TF_SET_ANDROID_WORKSPACE=0 \
TF_NEED_KAFKA=0 \
TF_NEED_IGNITE=0 \
TF_NEED_ROCM=0 \
TF_NEED_TENSORRT=0 \
TF_DOWNLOAD_CLANG=0 \
TF_MKL_ROOT="$TF_COMPILE_PATH/mklml_lnx" \
TF_ENABLE_XLA=0
./configure

bazel --output_user_root=$BAZEL_ROOT_PATH build --jobs 32 --action_env=LD_LIBRARY_PATH=/usr/lib64/nvidia --verbose_failures --config opt $(echo $CONFIG_XOPT) --config mkl //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package $OPWD
bazel --output_user_root=$BAZEL_ROOT_PATH shutdown

WHEEL_REBUILD_FOLDER=$(mktemp -d -p .)
TARGET_WHEEL=$(ls -Art $OPWD/*.whl | tail -n 1)
cd $WHEEL_REBUILD_FOLDER
unzip $TARGET_WHEEL 
find . -name libiomp5.so -delete
sed -i 's/libiomp5.so//g' *.dist-info/RECORD
zip -r $TARGET_WHEEL *.data/ *.dist-info/
cd ..
rm -rf $WHEEL_REBUILD_FOLDER

echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/$ARG_ARCH and synchronize CVMFS"
if [[ $ARG_DEBUG == 0 ]]; then
    rm -rf $TF_COMPILE_PATH
fi
