# fairseq2n is sub-package of fairseq2 that is not available from source on PyPI

PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/facebookresearch/fairseq2.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
MODULE_BUILD_DEPS='cuda/11.7 tbb'
MODULE_RUNTIME_DEPS='tbb'
PRE_BUILD_COMMANDS='
        cd fairseq2n;
        cmake -GNinja -DBUILD_TESTING=OFF -DFAIRSEQ2N_INSTALL_STANDALONE=ON -DFAIRSEQ2N_USE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="60;70;75;80;86" -DFAIRSEQ2N_BUILD_FOR_NATIVE=OFF -B build -S .;
        cmake --build build --parallel 4;
        cd python;
        sed -i "/tbb/d" setup.py;
'
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PATCHES='fairseq2n_fix_libs.patch'
