PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/TimDettmers/bitsandbytes"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --recursive $PACKAGE_DOWNLOAD_ARGUMENT $PACKAGE_FOLDER_NAME && git checkout ${VERSION:?version required}"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS='
	CUDA_VERSION=CPU make cpuonly GPP=$(which g++) -j 4;
	module load cuda/11.4 && CUDA_VERSION=114 make cuda11x GPP=$(which g++) -j 4;
	module load cuda/11.7 && CUDA_VERSION=117 make cuda11x GPP=$(which g++) -j 4;
'
MODULE_BUILD_DEPS='arch/avx2'
PYTHON_DEPS="torch numpy scipy"
