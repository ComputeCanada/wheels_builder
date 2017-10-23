#!/bin/bash
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

TEMP=$(getopt -o a:v: --longoptions version:,arch:,gpu,debug -n $0 -- "$@")
eval set -- "$TEMP"
ARG_VERSION=
ARG_ARCH=
ARG_GPU=0

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

module load gcc java bazel
if [[ $ARG_GPU == 1 ]]; then
    module load cuda/8.0.44 cudnn/5.1
fi

unset CPLUS_INCLUDE_PATH
unset C_INCLUDE_PATH

OPWD=$(pwd)
TF_COMPILE_PATH=/dev/shm/${USER}/tf_$(date +'%s')
export TMPDIR=$TF_COMPILE_PATH
BAZEL_ROOT_PATH=$TF_COMPILE_PATH/bazel
mkdir -p $TF_COMPILE_PATH; cd $TF_COMPILE_PATH

if [[ $ARG_DEBUG == 1 ]]; then
    echo "Debug mode - compilation results will be in: $TF_COMPILE_PATH"
fi

git clone https://github.com/tensorflow/tensorflow.git; cd tensorflow
git checkout $ARG_VERSION

GCC_PREFIX=$(dirname $(dirname $(which gcc)))
if [[ $ARG_GPU == 1 ]]; then
    CROSSTOOL_FILE=third_party/gpus/crosstool/CROSSTOOL_nvcc.tpl
else
    CROSSTOOL_FILE=third_party/toolchains/cpus/CROSSTOOL
fi

sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$GCC_PREFIX/lib64\"" $CROSSTOOL_FILE
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$GCC_PREFIX/lib\"" $CROSSTOOL_FILE
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$NIXUSER_PROFILE/lib\"" $CROSSTOOL_FILE
if [[ $ARG_GPU == 1 ]]; then
    sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$EBROOTCUDNN/lib64\"" $CROSSTOOL_FILE
    sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$EBROOTCUDA/lib64\"" $CROSSTOOL_FILE
fi
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-B$NIXUSER_PROFILE/lib\"" $CROSSTOOL_FILE
sed -i "s;/usr/bin;$NIXUSER_PROFILE/bin;g" $CROSSTOOL_FILE

include_paths=$(echo | gcc -xc++ -E -v - 2>&1 | grep '/include' | grep -v -P '(ignoring|#)' | xargs realpath)
for path in $include_paths ${CPATH//:/ }; do
    sed -i "\;cxx_flag: \"-std=c++11\"; a \
\ \ cxx_builtin_include_directory: \"$path\"" $CROSSTOOL_FILE
done

sed -i -r "s;bazel (clean|fetch|query); bazel --output_user_root=$BAZEL_ROOT_PATH \1;g" configure
sed -i -r "s;^_VERSION = '(.+)'$;_VERSION = '\1+computecanada';g" tensorflow/tools/pip_package/setup.py

# pass -O options when generating dependency
curl -L https://patch-diff.githubusercontent.com/raw/tensorflow/tensorflow/pull/10999.patch > 10999.patch
git apply 10999.patch

# setup our own project_name
if [[ $ARG_GPU == 1 ]]; then
    PKG_NAME="tensorflow_gpu"
else
   PKG_NAME="tensorflow_cpu"
fi
sed -i "s;setup.py bdist_wheel .* >/dev/null;setup.py bdist_wheel --project_name $PKG_NAME > /dev/null;g" tensorflow/tools/pip_package/build_pip_package.sh

virtualenv buildenv
source buildenv/bin/activate
pip install numpy wheel

if [[ $ARG_GPU == 1 ]]; then
    export\
    TF_NEED_CUDA=1 \
    TF_CUDA_VERSION=$(echo $EBVERSIONCUDA | grep -Po '\d.\d(?=.\d)') \
    CUDA_TOOLKIT_PATH=$CUDA_HOME \
    TF_CUDNN_VERSION=$(echo $EBVERSIONCUDNN | grep -Po '\d(?=.\d)') \
    CUDNN_INSTALL_PATH="$EBROOTCUDNN" \
    TF_CUDA_CLANG=0 \
    TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7,5.2,6.0,6.1"
    CONFIG_XOPT="--config cuda"
else
    export TF_NEED_CUDA=0
    CONFIG_XOPT=""
fi

export \
PYTHON_BIN_PATH=$(which python) \
USE_DEFAULT_PYTHON_LIB_PATH=1 \
TF_NEED_GCP=0 \
TF_NEED_HDFS=0 \
TF_NEED_OPENCL=0 \
TF_NEED_JEMALLOC=1 \
TF_NEED_MKL=0 \
TF_NEED_VERBS=0 \
TF_NEED_MPI=0 \
TF_ENABLE_XLA=0 \
GCC_HOST_COMPILER_PATH=$(which gcc)
./configure

# --action_env=NIXUSER_PROFILE 
bazel --output_user_root=$BAZEL_ROOT_PATH build --verbose_failures --config opt $CONFIG_XOPT //tensorflow/tools/pip_package:build_pip_package

bazel-bin/tensorflow/tools/pip_package/build_pip_package $OPWD
bazel --output_user_root=$BAZEL_ROOT_PATH shutdown

echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/$ARG_ARCH and synchronize CVMFS"
if [[ $ARG_DEBUG == 0 ]]; then
    rm -rf $TF_COMPILE_PATH
fi
