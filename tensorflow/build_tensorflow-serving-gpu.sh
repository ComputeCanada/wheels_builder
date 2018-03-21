# Compiling tensorflow-serving

OPWD=$(pwd)
TF_COMPILE_PATH=/dev/shm/${USER}/tf_$(date +'%s')
export TMPDIR=$TF_COMPILE_PATH
BAZEL_ROOT_PATH=$TF_COMPILE_PATH/bazel
mkdir -p $TF_COMPILE_PATH; cd $TF_COMPILE_PATH

git clone --recurse-submodules https://github.com/tensorflow/serving
cd serving
git checkout 1.4.0
git submodule update

module load gcc bazel cuda cudnn python/2
virtualenv buildenv
source buildenv/bin/activate
pip install tensorflow-cpu==1.4.0

unset CPLUS_INCLUDE_PATH
unset C_INCLUDE_PATH

cd tensorflow
GCC_PREFIX=$(dirname $(dirname $(which gcc)))
CROSSTOOL_FILE=third_party/gpus/crosstool/CROSSTOOL_nvcc.tpl

sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$GCC_PREFIX/lib64\"" $CROSSTOOL_FILE
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$GCC_PREFIX/lib\"" $CROSSTOOL_FILE
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$NIXUSER_PROFILE/lib\"" $CROSSTOOL_FILE
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$EBROOTCUDNN/lib64\"" $CROSSTOOL_FILE
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-Wl,-rpath=$EBROOTCUDA/lib64\"" $CROSSTOOL_FILE
sed -i "\;linker_flag: \"-B/usr/bin/\";a \ \ linker_flag: \"-B$NIXUSER_PROFILE/lib\"" $CROSSTOOL_FILE
sed -i "s;/usr/bin;$NIXUSER_PROFILE/bin;g" $CROSSTOOL_FILE

include_paths=$(echo | gcc -xc++ -E -v - 2>&1 | grep '/include' | grep -v -P '(ignoring|#)' | xargs realpath)
for path in $include_paths ${CPATH//:/ }; do
    sed -i "\;cxx_flag: \"-std=c++11\"; a \
\ \ cxx_builtin_include_directory: \"$path\"" $CROSSTOOL_FILE
done

export \
TF_NEED_CUDA=1 \
TF_CUDA_VERSION=$(echo $EBVERSIONCUDA | grep -Po '\d.\d(?=.\d)') \
CUDA_TOOLKIT_PATH=$CUDA_HOME \
TF_CUDNN_VERSION=$(echo $EBVERSIONCUDNN | grep -Po '\d(?=.\d)') \
CUDNN_INSTALL_PATH="$EBROOTCUDNN" \
TF_CUDA_CLANG=0 \
TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7,5.2,6.0,6.1" \
TF_NEED_MPI=0 \
TF_NEED_GDR=0 \
TF_NEED_VERBS=0 \
GCC_HOST_COMPILER_PATH=$(which gcc) \

export \
PYTHON_BIN_PATH=$(which python) \
USE_DEFAULT_PYTHON_LIB_PATH=1 \
TF_NEED_S3=0 \
TF_NEED_GCP=0 \
TF_NEED_HDFS=0 \
TF_NEED_OPENCL=0 \
TF_NEED_OPENCL_SYCL=0 \
TF_NEED_JEMALLOC=1 \
TF_SET_ANDROID_WORKSPACE=0 \
TF_ENABLE_XLA=0

./configure
cd ..
cp tensorflow/.bazelrc tensorflow/.tf_configure.bazelrc .

#sed -i '182,212s/^/# /' 

#bazel --output_user_root=$BAZEL_ROOT_PATH build --verbose_failures -c opt --copt=-msse4.1 --copt=-msse4.2 --copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-O3 --config monolithic tensorflow_serving/...
# --config monolithic
bazel --output_user_root=$BAZEL_ROOT_PATH build --verbose_failures -c opt --copt=-msse4.1 --copt=-msse4.2 --copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-O3 --config monolithic --config cuda --crosstool_top=@local_config_cuda//crosstool:toolchain tensorflow_serving/model_servers:tensorflow_model_server
cp bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server ${OPWD}/tensorflow_model_server_gpu
