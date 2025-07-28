# cuda 12.6 with cccl has a bug : https://github.com/dmlc/xgboost/issues/10894, so use 12.2
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12.2 nccl cmake"
else
	MODULE_BUILD_DEPS="cuda/11.4 nccl cmake"
fi
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/dmlc/xgboost.git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS="
        mkdir build &&
        cd build && 
        cmake .. -DCMAKE_CUDA_ARCHITECTURES='70;80;90' -DUSE_CUDA=ON -DUSE_NCCL=ON -DNCCL_ROOT=$EBROOTNCCL &&
        make -j4 && cd ../python-package/;
        sed -i -e '/nvidia-.*-cu12/d' pyproject.toml;
"
