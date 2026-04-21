# The version is the one from GPU4PySCF, not GPU4PySCF-libxc as it differs.
# I wish it was bundled instead of a seperate dependency.
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pyscf/gpu4pyscf.git@v${VERSION:?version required}"
MODULE_RUNTIME_DEPS='cuda/12.9'
PRE_BUILD_COMMANDS='
	verify_and_patch_arch_flags;
	sed -i -e "s/-cuda{CUDA_VERSION}//" -e "s/ + '\''-cuda'\'' + CUDA_VERSION//" setup.py builder/setup_libxc.py;
	cmake -S gpu4pyscf/lib -B _build-libxc -DBUILD_SOLVENT=OFF -DCUDA_ARCHITECTURES="80;90;100";
	cmake --build _build-libxc/ --parallel $SLURM_CPUS_PER_TASK;
	mv -v builder/setup_libxc.py setup.py;
'
	# python builder/setup_libxc.py bdist_wheel;
	# rm setup.py;
PYTHON_IMPORT_NAME=""
