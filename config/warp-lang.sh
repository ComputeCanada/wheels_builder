MODULE_BUILD_DEPS='cuda/13 libmathdx'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/NVIDIA/warp"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PRE_BUILD_COMMANDS='
	sed -i -e "s/--strip-all//" warp/_src/build_dll.py;
	python build_lib.py --mode release --verbose --no-build-llvm -j ${SLURM_CPUS_PER_TASK:-1} --use-dynamic-cuda --libmathdx-path=$EBROOTLIBMATHDX;
'
POST_BUILD_COMMANDS='wheel tags --remove --platform-tag=linux_x86_64 $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
PYTHON_IMPORT_NAME='warp'
