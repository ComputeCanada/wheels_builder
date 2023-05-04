MODULE_BUILD_DEPS='gcc cmake cubic_interpolation spdlog eigen boost'
PRE_BUILD_COMMANDS='
	export BUILD_CORES=4;
	export NO_CONAN=1;
	sed -i "/'\''-DBUILD_TESTING=OFF'\'',/a '\''-DBoost_NO_BOOST_CMAKE=ON'\''," setup.py;
'
