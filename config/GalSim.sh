MODULE_BUILD_DEPS='fftw eigen'
PRE_BUILD_COMMANDS='
	export FFTW_DIR=$EBROOTFFTW;
	export EIGEN_DIR=$EBROOTEIGEN;
	sed -i -e "839,840d" setup.py
'
PYTHON_DEPS='setuptools<72'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/GalSim-developers/GalSim/archive/refs/tags/v${VERSION:?version required}.tar.gz"
