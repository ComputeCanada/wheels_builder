# The v0.2 is CPU only, GPU is in HEAD of the repo or the next release
PACKAGE="dgl"
PACKAGE_SUFFIX="-gpu"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PYTHON_IMPORT_NAME=$PACKAGE
PACKAGE_FOLDER_NAME=$PACKAGE
MODULE_BUILD_DEPS="cmake cuda/11.4 nccl cudnn"
PYTHON_DEPS="cython numpy>=1.21.2 scipy networkx torch==1.10.0"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/dmlc/dgl"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch $VERSION $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS="mkdir build && cd build && cmake -DUSE_OPENMP=ON -DUSE_CUDA=ON -DUSE_NCCL=ON -DUSE_SYSTEM_NCCL=ON -DBUILD_TORCH=ON .. && export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0' && make -j 4 && cd ../python "
# libdgl is not found, patch runpath
POST_BUILD_COMMANDS='setrpaths.sh --path $WHEEL_NAME --add_path \$ORIGIN/../.. --any_interpreter'
