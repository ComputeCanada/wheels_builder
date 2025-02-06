PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mdolab/adflow/archive/refs/tags/v${VERSION:?version required}.tar.gz"
MODULE_RUNTIME_DEPS='openmpi mpi4py'
MODULE_BUILD_DEPS='cgns petsc'
PRE_BUILD_COMMANDS='
	cp config/defaults/config.LINUX_GFORTRAN.mk config/config.mk;
	sed -i -e "s/-march=native/-O3 -ftree-vectorize -march=x86-64-v3 -fno-math-errno/" config/config.mk;
	export CGNS_HOME=$EBROOTCGNS;
	make -j LINKER_FLAGS="-Wl,-rpath,$EBROOTCGNS/lib";
'
POST_BUILD_COMMANDS='wheel tags --remove --abi-tag=none --python-tag=py3 --platform-tag=linux_x86_64 $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
PYTHON_DEPS='numpy>=2.2.0' # bug in f2py in prior versions
