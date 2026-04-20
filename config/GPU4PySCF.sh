PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pyscf/gpu4pyscf.git@v${VERSION:?version required}"
MODULE_RUNTIME_DEPS='cuda/12.9'
PRE_BUILD_COMMANDS='
	export CMAKE_CONFIGURE_ARGS=-DCUDA_ARCHITECTURES="80;90;100";
	export CMAKE_BUILD_ARGS="--parallel $SLURM_CPUS_PER_TASK";
	sed -i -e "s/-cuda{CUDA_VERSION}//" -e "s/ + '\''-cuda'\'' + CUDA_VERSION//" setup.py builder/setup_libxc.py;


'
