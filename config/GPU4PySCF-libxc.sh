# The version is the one from GPU4PySCF, not GPU4PySCF-libxc as it differs.
# I wish it was bundled instead of a seperate dependency.
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pyscf/gpu4pyscf.git@v${VERSION:?version required}"
MODULE_RUNTIME_DEPS='cuda/13'
PRE_BUILD_COMMANDS='
	verify_and_patch_arch_flags;
	sed -i -e "s/-cuda{CUDA_VERSION}//" -e "s/ + '\''-cuda'\'' + CUDA_VERSION//" setup.py builder/setup_libxc.py;
    sed -i "s/GIT_TAG\s\+v3\.[0-5]\.[0-9]/GIT_TAG v3.6.0/g" gpu4pyscf/lib/CMakeLists.txt;
	cmake -S gpu4pyscf/lib -B _build-libxc -DBUILD_SOLVENT=OFF -DCUDA_ARCHITECTURES="80;90;100";
	cmake --build _build-libxc/ --parallel $SLURM_CPUS_PER_TASK;
	mv -v builder/setup_libxc.py setup.py;
'
PYTHON_IMPORT_NAME=""
