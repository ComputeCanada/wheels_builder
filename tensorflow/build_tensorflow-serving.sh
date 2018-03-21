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

module load gcc bazel python/2
virtualenv buildenv
source buildenv/bin/activate
#pip install tensorflow-cpu==1.4.0
pip install numpy

unset CPLUS_INCLUDE_PATH
unset C_INCLUDE_PATH

cd tensorflow
export TF_NEED_CUDA=0 TF_NEED_MPI=0 TF_NEED_GDR=0 TF_NEED_VERBS=0 GCC_HOST_COMPILER_PATH=$(which gcc) PYTHON_BIN_PATH=$(which python) USE_DEFAULT_PYTHON_LIB_PATH=1 TF_NEED_S3=0 TF_NEED_GCP=0 TF_NEED_HDFS=0 TF_NEED_OPENCL=0 TF_NEED_OPENCL_SYCL=0 TF_NEED_JEMALLOC=1 TF_SET_ANDROID_WORKSPACE=0 TF_ENABLE_XLA=0
./configure
cd ..
cp tensorflow/.bazelrc tensorflow/.tf_configure.bazelrc .

#sed -i '182,212s/^/# /' 

#bazel --output_user_root=$BAZEL_ROOT_PATH build --verbose_failures -c opt --copt=-msse4.1 --copt=-msse4.2 --copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-O3 --config monolithic tensorflow_serving/...
bazel --output_user_root=$BAZEL_ROOT_PATH build --verbose_failures -c opt --copt=-msse4.1 --copt=-msse4.2 --copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-O3 --config monolithic tensorflow_serving/model_servers:tensorflow_model_server
cp bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server ${OPWD}/

