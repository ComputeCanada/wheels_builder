# MACH-AERO cgnsutilities

PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mdolab/cgnsutilities/archive/refs/tags/v${VERSION:?version required}.tar.gz"
MODULE_BUILD_DEPS='openmpi cgns'
PYTHON_DEPS='numpy>=2.2.0' # bug in f2py in prior versions
PRE_BUILD_COMMANDS='
	cp config/defaults/config.LINUX_GFORTRAN.mk config/config.mk;
	sed -i -e "s/-O2/-O2 -ftree-vectorize -march=x86-64-v3 -fno-math-errno/" config/config.mk;
	export CGNS_HOME=$EBROOTCGNS;
	make -j ;
'
# Fix tags
POST_BUILD_COMMANDS='wheel tags --remove --abi-tag=none --python-tag=py3 --platform-tag=linux_x86_64 $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
