set -e
module load gcc cuda/8.0.44 cudnn/5.1 bazel/0.5.2
 
OPWD=$(pwd)
TF_COMPILE_PATH=/tmp/${USER}_$(date +'%s')
BAZEL_ROOT_PATH=$TF_COMPILE_PATH/bazel
mkdir -p $TF_COMPILE_PATH; cd $TF_COMPILE_PATH
git clone https://github.com/tensorflow/tensorflow.git; cd tensorflow
git checkout v1.0.1
 
GCC_PREFIX=$(dirname $(dirname $(which gcc)))
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$GCC_PREFIX/lib64\"" third_party/gpus/crosstool/CROSSTOOL.tpl
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$GCC_PREFIX/lib\"" third_party/gpus/crosstool/CROSSTOOL.tpl

CROSSTOOL_FILE=third_party/gpus/crosstool/CROSSTOOL.tpl
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$NIXUSER_PROFILE/lib\"" $CROSSTOOL_FILE
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$EBROOTCUDNN/lib64\"" $CROSSTOOL_FILE
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$EBROOTCUDA/lib64\"" $CROSSTOOL_FILE
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-B$NIXUSER_PROFILE/lib\"" $CROSSTOOL_FILE
sed -i "s;/usr/bin;$NIXUSER_PROFILE/bin;g" $CROSSTOOL_FILE

sed -i "/cmd = 'PATH=' + PREFIX_DIR + ' ' + cmd/s/^/#/" third_party/gpus/crosstool/clang/bin/crosstool_wrapper_driver_is_not_gcc.tpl
sed -i -r "s;bazel (clean|fetch|query); bazel --output_user_root=$BAZEL_ROOT_PATH \1;g" configure
sed -i -r "s;^_VERSION = '(.+)'$;_VERSION = '\1+computecanada';g" tensorflow/tools/pip_package/setup.py

include_paths=$(echo | gcc -xc++ -E -v - 2>&1 | grep '/include' | grep -v -P '(ignoring|#)' | xargs realpath)
include_paths="$include_paths /cvmfs/soft.computecanada.ca/nix/var/nix/profiles/gcc-5.4.0/lib/gcc/x86_64-unknown-linux-gnu/5.4.0/include /cvmfs/soft.computecanada.ca/nix/var/nix/profiles/gcc-5.4.0/lib/gcc/x86_64-unknown-linux-gnu/5.4.0/include-fixed "
for path in $include_paths ${CPATH//:/ }; do
    sed -i "\;cxx_flag: \"-std=c++11\"; a \
\ \ cxx_builtin_include_directory: \"$path\"" third_party/gpus/crosstool/CROSSTOOL.tpl
done

PKG_NAME="tensorflow_gpu"
sed -i "s;setup.py bdist_wheel .* >/dev/null;setup.py bdist_wheel --project_name $PKG_NAME > /dev/null;g" tensorflow/tools/pip_package/build_pip_package.sh
 
module load python/2
#module load python/3.6
virtualenv buildenv
source buildenv/bin/activate
pip install numpy wheel
 
#export MALLOC_ARENA_MAX=4

export CC_OPT_FLAGS="-march=core-avx2"

export PYTHON_BIN_PATH=$(which python) \
USE_DEFAULT_PYTHON_LIB_PATH=1 \
TF_NEED_GCP=0 \
TF_NEED_HDFS=0 \
TF_NEED_OPENCL=0 \
TF_NEED_CUDA=1 \
TF_NEED_JEMALLOC=0 \
TF_ENABLE_XLA=0 \
GCC_HOST_COMPILER_PATH=$(which gcc) \
TF_CUDA_VERSION=$(echo $EBVERSIONCUDA | grep -Po '\d.\d(?=.\d)') \
CUDA_TOOLKIT_PATH=$CUDA_HOME \
TF_CUDNN_VERSION=$(echo $EBVERSIONCUDNN | grep -Po '\d(?=.\d)') \
CUDNN_INSTALL_PATH="$EBROOTCUDNN" \
TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7,5.2,6.0,6.1"

./configure
bazel --output_user_root=$BAZEL_ROOT_PATH build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package
 
mkdir dist; bazel-bin/tensorflow/tools/pip_package/build_pip_package $PWD/dist
cp dist/*.whl $OPWD
bazel --output_user_root=$BAZEL_ROOT_PATH shutdown
cd
rm -rf $TF_COMPILE_PATH
