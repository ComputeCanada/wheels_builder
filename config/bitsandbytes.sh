PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/TimDettmers/bitsandbytes"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --recursive $PACKAGE_DOWNLOAD_ARGUMENT $PACKAGE_FOLDER_NAME && cd $PACKAGE_FOLDER_NAME && git checkout ${VERSION:?version required} && cd .."
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
PYTHON_DEPS="setuptools>=77.0.3"
MODULE_BUILD_DEPS='cuda/12.2'
MODULE_RUNTIME_DEPS='cuda/12'
# Builds the differents SOs into the source directory
PRE_BUILD_COMMANDS='
	cmake -G Ninja  -B _build_cpu -S . -DCOMPUTE_BACKEND=cpu -DCMAKE_BUILD_TYPE=Release;
	cmake --build _build_cpu --parallel ${SLURM_CPUS_PER_TASK:-4} --config Release;

	for cudaver in 12.2 12.6; do
		module load cuda/$cudaver && cmake -G Ninja  -B _build-$EBVERSIONCUDACORE -S . -DCOMPUTE_BACKEND=cuda -DCOMPUTE_CAPABILITY="70;80;90" -DCMAKE_BUILD_TYPE=Release;
		cmake --build _build-$EBVERSIONCUDACORE --parallel ${SLURM_CPUS_PER_TASK:-4} --config Release;
	done
'
# pypi wheel is py3
POST_BUILD_COMMANDS='wheel tags --remove --abi-tag=none --python-tag=py3 --platform-tag=linux_x86_64 $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
