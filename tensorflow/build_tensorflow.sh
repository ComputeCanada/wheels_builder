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
ARG_DEBUG=0

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

if [[ $ARG_ARCH == "avx2" ]]; then
    export CC_OPT_FLAGS="-march=core-avx2 -O2"
elif [[ $ARG_ARCH == "avx" ]]; then
    export CC_OPT_FLAGS="-march=corei7-avx -O2"
elif [[ $ARG_ARCH == "sse3" ]]; then
    export CC_OPT_FLAGS="-march=nocona -mtune=generic -O2"
else
   usage; exit 1
fi

module load gcc java bazel imkl
if [[ $ARG_GPU == 1 ]]; then
    module load cuda/9.0.176 cudnn/7.0
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

#git clone https://github.com/tensorflow/tensorflow.git; cd tensorflow
#git checkout $ARG_VERSION
git clone -b $ARG_VERSION --single-branch --depth 1 https://github.com/tensorflow/tensorflow.git
cd tensorflow

GCC_PREFIX=$(dirname $(dirname $(which gcc)))
if [[ $ARG_GPU == 1 ]]; then
    CROSSTOOL_FILE=third_party/gpus/crosstool/CROSSTOOL.tpl
    sed -i -r "\;^ *flag: \"-B/usr/bin/\";a \ \ \ \ \ \ \ \ flag: \"-Wl,-rpath=$EBROOTCUDNN/lib64\"" $CROSSTOOL_FILE
    for path in $(find $EBROOTCUDA -name lib64); do
        sed -i -r "\;^ *flag: \"-B/usr/bin/\";a \ \ \ \ \ \ \ \ flag: \"-Wl,-rpath=$path\"" $CROSSTOOL_FILE
    done
    sed -i -r "\;^ *flag: \"-B/usr/bin/\";a \ \ \ \ \ \ \ \ flag: \"-Wl,-rpath=/usr/lib64/nvidia\"" $CROSSTOOL_FILE
    sed -i -r "\;^ *flag: \"-B/usr/bin/\";a \ \ \ \ \ \ \ \ flag: \"-Wl,-rpath=$EBROOTIMKL/compilers_and_libraries/linux/lib/intel64_lin\"" $CROSSTOOL_FILE
    sed -i -r "\;^ *flag: \"-B/usr/bin/\";a \ \ \ \ \ \ \ \ flag: \"-B$NIXUSER_PROFILE/lib/\"" $CROSSTOOL_FILE
    sed -i "s;/usr/bin;$NIXUSER_PROFILE/bin;g" $CROSSTOOL_FILE
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
    # TF 1.9.0: Patch for MPI collectives
    #git cherry-pick -m 1 -n 5ac1bd7836e0f1a4d3b02f9538c4277914c8e5f5
    # TF 1.11.0 ISSUE 21999
    git cherry-pick -n c67ded664a20f27b4e90020bf76a097b462182b1
    git apply $SCRIPT_DIR/tensorflow-mpi.patch

    export \
    TF_NEED_CUDA=1 \
    TF_CUDA_VERSION=$(echo $EBVERSIONCUDA | grep -Po '\d.\d(?=.\d)') \
    CUDA_TOOLKIT_PATH=$CUDA_HOME \
    TF_CUDNN_VERSION=$(echo $EBVERSIONCUDNN | grep -Po '\d(?=.\d)') \
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
TF_NEED_TENSORRT=0 \
TF_DOWNLOAD_CLANG=0 \
TF_MKL_ROOT="$TF_COMPILE_PATH/mklml_lnx" \
TF_ENABLE_XLA=0
./configure

bazel --io_nice_level=4 --output_user_root=$BAZEL_ROOT_PATH build --jobs 28 --ram_utilization_factor 40 --action_env=LD_LIBRARY_PATH=/usr/lib64/nvidia --verbose_failures --config opt $(echo $CONFIG_XOPT) --config mkl //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package $OPWD
bazel --output_user_root=$BAZEL_ROOT_PATH shutdown

WHEEL_REBUILD_FOLDER=$(mktemp -d -p .)
TARGET_WHEEL=$(ls -Art $OPWD/*.whl | tail -n 1)
cd $WHEEL_REBUILD_FOLDER
unzip $TARGET_WHEEL 
find . -name libiomp5.so -exec ln -sf $EBROOTIMKL/compilers_and_libraries/linux/lib/intel64_lin/libiomp5.so {} \;
zip --symlinks -r $TARGET_WHEEL *.data/ *.dist-info/
cd ..
rm -rf $WHEEL_REBUILD_FOLDER

echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/$ARG_ARCH and synchronize CVMFS"
if [[ $ARG_DEBUG == 0 ]]; then
    rm -rf $TF_COMPILE_PATH
fi
