#!/bin/bash
set -e

function usage() {
    echo "Usage:"
    echo "Load a python module then, call"
    echo "$0 <version_tag>"
}

if ! module -t list | grep -q python; then
   usage
   exit
fi
if [[ -z "$1" ]]; then
   usage
   exit
fi
TF_VERSION=$1

module load gcc cuda/8.0.44 cudnn/5.1 java bazel

OPWD=$(pwd)
TF_COMPILE_PATH=/dev/shm/${USER}/tf_$(date +'%s')
export TMPDIR=$TF_COMPILE_PATH
BAZEL_ROOT_PATH=$TF_COMPILE_PATH/bazel
mkdir -p $TF_COMPILE_PATH; cd $TF_COMPILE_PATH

git clone https://github.com/tensorflow/tensorflow.git; cd tensorflow
git checkout $TF_VERSION

GCC_PREFIX=$(dirname $(dirname $(which gcc)))
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$GCC_PREFIX/lib64\"" third_party/gpus/crosstool/CROSSTOOL_nvcc.tpl
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$GCC_PREFIX/lib\"" third_party/gpus/crosstool/CROSSTOOL_nvcc.tpl
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$NIXUSER_PROFILE/lib\"" third_party/gpus/crosstool/CROSSTOOL_nvcc.tpl
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$EBROOTCUDNN/lib64\"" third_party/gpus/crosstool/CROSSTOOL_nvcc.tpl
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$EBROOTCUDA/lib64\"" third_party/gpus/crosstool/CROSSTOOL_nvcc.tpl
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-B$NIXUSER_PROFILE/lib\"" third_party/gpus/crosstool/CROSSTOOL_nvcc.tpl
sed -i "s;/usr/bin;$NIXUSER_PROFILE/bin;g" third_party/gpus/crosstool/CROSSTOOL_nvcc.tpl

include_paths=$(echo | gcc -xc++ -E -v - 2>&1 | grep '/include' | grep -v -P '(ignoring|#)' | xargs realpath)
for path in $include_paths ${CPATH//:/ }; do
    sed -i "\;cxx_flag: \"-std=c++11\"; a \
\ \ cxx_builtin_include_directory: \"$path\"" third_party/gpus/crosstool/CROSSTOOL_nvcc.tpl
done

sed -i -r "s;bazel (clean|fetch|query); bazel --output_user_root=$BAZEL_ROOT_PATH \1;g" configure
sed -i -r "s;^_VERSION = '(.+)'$;_VERSION = '\1+computecanada';g" tensorflow/tools/pip_package/setup.py

virtualenv buildenv
source buildenv/bin/activate
pip install numpy wheel

export \
PYTHON_BIN_PATH=$(which python) \
USE_DEFAULT_PYTHON_LIB_PATH=1 \
TF_NEED_GCP=0 \
TF_NEED_HDFS=0 \
TF_NEED_OPENCL=0 \
TF_NEED_CUDA=1 \
TF_NEED_JEMALLOC=1 \
TF_NEED_MKL=0 \
TF_NEED_VERBS=0 \
TF_ENABLE_XLA=0 \
TF_CUDA_CLANG=0 \
GCC_HOST_COMPILER_PATH=$(which gcc) \
TF_CUDA_VERSION=$(echo $EBVERSIONCUDA | grep -Po '\d.\d(?=.\d)') \
CUDA_TOOLKIT_PATH=$CUDA_HOME \
TF_CUDNN_VERSION=$(echo $EBVERSIONCUDNN | grep -Po '\d(?=.\d)') \
CUDNN_INSTALL_PATH="$EBROOTCUDNN" \
TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7,5.2,6.0,6.1" \
CC_OPT_FLAGS="-march=native"
./configure

bazel --output_user_root=$BAZEL_ROOT_PATH build --verbose_failures --config opt --config cuda //tensorflow/tools/pip_package:build_pip_package

bazel-bin/tensorflow/tools/pip_package/build_pip_package $OPWD
bazel --output_user_root=$BAZEL_ROOT_PATH shutdown

echo "Build done, you can now remove $TF_COMPILE_PATH"
echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/avx2 and synchronize CVMFS"