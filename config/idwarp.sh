# MACH-AERO IDWarp
# https://mdolab-idwarp.readthedocs-hosted.com/en/latest/building.html#requirements
MODULE_RUNTIME_DEPS='openmpi petsc cgns mpi4py'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mdolab/idwarp/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS='
	export CGNS_HOME=$EBROOTCGNS;
	cp config/defaults/config.LINUX_GFORTRAN*.mk config/config.mk;
	make -j LINKER_FLAGS="-Wl,-rpath,$EBROOTCGNS/lib";
'
PYTHON_DEPS='numpy>=2.2.0' # bug in f2py in prior versions
# Fix tags
POST_BUILD_COMMANDS='wheel tags --remove --abi-tag=none --python-tag=py3 --platform-tag=linux_x86_64 $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
