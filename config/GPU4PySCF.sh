PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pyscf/gpu4pyscf.git@v${VERSION:?version required}"
MODULE_RUNTIME_DEPS='cuda/13'
PRE_BUILD_COMMANDS='
	export CMAKE_CONFIGURE_ARGS=-DCUDA_ARCHITECTURES="80;90;100";
	export CMAKE_BUILD_ARGS="--parallel $SLURM_CPUS_PER_TASK";
    export GPU4PYSCF_BUILD_CUDA_WHEEL=1;
	sed -i -e "s/-cuda{CUDA_VERSION}//" -e "s/ + '\''-cuda'\'' + CUDA_VERSION//" setup.py builder/setup_libxc.py;
    sed -i "s/GIT_TAG\s\+v3\.[0-5]\.[0-9]/GIT_TAG v3.6.0/g" gpu4pyscf/lib/CMakeLists.txt;
'
