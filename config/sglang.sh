MODULE_BUILD_DEPS='cuda/13 protobuf'
MODULE_RUNTIME_DEPS='arrow'
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PRE_BUILD_COMMANDS='
	cd python;
	export CARGO_BUILD_JOBS=${SLURM_CPUS_PER_TASK:-1};
	export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1;
	sed -i -e "s/sglang-kernel==/sglang-kernel~=/" -e "s/nvidia-cutlass-dsl\[cu13\]/nvidia-cutlass-dsl/" -e "s/flashinfer_python\[cu13\]/flashinfer_python/" pyproject.toml
'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/sgl-project/sglang.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --jobs 16 --depth 1 --shallow-submodules --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
