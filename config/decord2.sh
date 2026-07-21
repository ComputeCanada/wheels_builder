MODULE_BUILD_DEPS='cuda/13 ffmpeg'
PRE_BUILD_COMMANDS='
	cmake --fresh -B build -DUSE_CUDA=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_ARCHITECTURES="80;90;100-real;100-virtual";
	cmake --build build --parallel ${SLURM_CPUS_PER_TASK:-1};
	cd python;
'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/johnnynunez/decord2.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --shallow-submodules --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
