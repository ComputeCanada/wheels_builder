PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/TimDettmers/bitsandbytes"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --recursive $PACKAGE_DOWNLOAD_ARGUMENT $PACKAGE_FOLDER_NAME && cd $PACKAGE_FOLDER_NAME && git checkout ${VERSION:?version required} && cd .."
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"

MODULE_BUILD_DEPS='cuda/12'
MODULE_RUNTIME_DEPS='cuda/12'
# Builds the differents SOs into the source directory
PRE_BUILD_COMMANDS='
	cmake -B _build -S . -DCOMPUTE_BACKEND=cpu;
	cmake --build _build --parallel 16;
	cmake -B _build -S . -DCOMPUTE_BACKEND=cuda -DCOMPUTE_CAPABILITY="60;70;75;80;86" -DNO_CUBLASLT=OFF;
	cmake --build _build --parallel 16;
	cmake -B _build -S . -DCOMPUTE_BACKEND=cuda -DCOMPUTE_CAPABILITY="60;70;75;80;86" -DNO_CUBLASLT=ON;
	cmake --build _build --parallel 16;
'
