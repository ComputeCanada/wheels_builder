#!/bin/bash
# Useful stack overflow thread
# https://stackoverflow.com/questions/37761469/how-to-add-external-header-files-during-bazel-tensorflow-build
# https://stackoverflow.com/questions/43921911/how-to-resolve-bazel-undeclared-inclusions-error
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

# export TF_COMPILE_PATH=/tmp/${USER}/tf_$(date +'%s')
export TF_COMPILE_PATH=/tmp/${USER}/tf_temp

# make sure we don't fill up /mnt/tmp
shopt -s nullglob
rm -rf /tmp/${USER}/tf_*
shopt -u nullglob

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMP=$(getopt -o a:v: --longoptions version:,arch:,gpu,debug -n $0 -- "$@")
eval set -- "$TEMP"
ARG_VERSION=
ARG_ARCH=
ARG_GPU=0
ARG_DEBUG=0
# whether to bundle the CC api or not
ARG_CCAPI=1

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
        --no-ccapi)
            ARG_CCAPI=0; shift ;;
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

# LOAD MODULES

module load \
	gcc/7.3.0 \
	java \
	bazel/0.25.2 \
	imkl

if [[ $ARG_GPU == 1 ]]; then
    module load \
	    cuda/10.0.130 \
	    cudnn/7.5 \
	    openmpi/2.1.1 \
	    nccl/2.4.2
fi

unset CPLUS_INCLUDE_PATH
unset C_INCLUDE_PATH

OPWD=$(pwd)
export TMPDIR=$TF_COMPILE_PATH
export TMP=$TMPDIR
export BAZEL_ROOT_PATH=$TF_COMPILE_PATH/bazel
mkdir -p $TF_COMPILE_PATH; cd $TF_COMPILE_PATH

if [[ $ARG_DEBUG == 1 ]]; then
    echo "Debug mode - compilation results will be in: $TF_COMPILE_PATH"
fi

git clone https://github.com/tensorflow/tensorflow.git;
#tar xf /home/fafor10/tensorflow.tar.gz
cd tensorflow
git pull
git checkout $ARG_VERSION
#git cherry-pick -n 03e63a291bc95dacaa821585f39a360b43465cb5

GCC_PREFIX=$(dirname $(dirname $(which gcc)))
if [[ $ARG_GPU == 1 ]]; then
    sed -i "s/which(\"ldconfig\")/which('echo')/g" third_party/gpus/find_cuda_config.py

    sed -i "\;host_compiler_includes = get_cxx_inc_directories;a \ \ \ \ host_compiler_includes += \[\"/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/gcc-7.3.0/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include/\"\]" third_party/gpus/cuda_configure.bzl
    sed -i "\;host_compiler_includes = get_cxx_inc_directories;a \ \ \ \ host_compiler_includes += \[\"/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/gcc-7.3.0/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include-fixed/\"\]" third_party/gpus/cuda_configure.bzl
    sed -i "\;host_compiler_includes = get_cxx_inc_directories;a \ \ \ \ host_compiler_includes += \[\"/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/gcc-7.3.0/include/c++/7.3.0/\"\]" third_party/gpus/cuda_configure.bzl
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
    git apply $SCRIPT_DIR/tensorflow-1.14-mpi.patch
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
    GCC_HOST_COMPILER_PREFIX="$EBROOTNIXPKGS/bin" \
    GCC_HOST_COMPILER_PATH=$(which mpicc) \
    TF_NCCL_VERSION="$EBVERSIONNCCL" \
    NCCL_INSTALL_PATH="$EBROOTNCCL" \
    MPI_HOME="$EBROOTOPENMPI"
#    CONFIG_XOPT="--config cuda"
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

N_JOBS=$(grep -c ^processor /proc/cpuinfo)

TARGETS="//tensorflow/tools/pip_package:build_pip_package "
if [[ $ARG_CCAPI == 1 ]] ; then
    TARGETS="${TARGETS} //tensorflow:libtensorflow_cc.so"
fi

echo "Building targets $TARGETS"

bazel \
    --output_user_root=$BAZEL_ROOT_PATH \
    build \
        --jobs $N_JOBS \
        --action_env=LD_LIBRARY_PATH=$EBROOTCUDA/lib64 \
        --verbose_failures \
        --config opt \
        --config mkl \
        $(echo $CONFIG_XOPT) \
        $(echo $TARGETS)

bazel-bin/tensorflow/tools/pip_package/build_pip_package $OPWD
bazel --output_user_root=$BAZEL_ROOT_PATH shutdown

WHEEL_REBUILD_FOLDER=$(mktemp -d -p .)
TARGET_WHEEL=$(ls -Art $OPWD/*.whl | tail -n 1)
cd $WHEEL_REBUILD_FOLDER
unzip $TARGET_WHEEL 
chmod -R 777 *.data
find . -name libiomp5.so -delete
sed -i 's/libiomp5.so//g' *.dist-info/RECORD

# Delete wheel otherwise zip just refresh content and keep libiomp5
rm $TARGET_WHEEL

if [[ $ARG_CCAPI == 1 ]] ; then
    cp $TF_COMPILE_PATH/tensorflow/bazel-bin/tensorflow/libtensorflow_cc.so *.data/purelib/tensorflow/
fi

# Add runtime paths
setrpaths.sh --path *.data --add_path $EBROOTNCCL/lib
setrpaths.sh --path *.data --add_path $EBROOTCUDNN/lib64
for path in $(find $EBROOTCUDA -name lib64)
do
   setrpaths.sh --path *.data --add_path $path
done

zip -r $TARGET_WHEEL *.data/ *.dist-info/
cd ..
rm -rf $WHEEL_REBUILD_FOLDER

echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/$ARG_ARCH and synchronize CVMFS"
if [[ $ARG_DEBUG == 0 ]]; then
    rm -rf $TF_COMPILE_PATH
fi
