MODULE_BUILD_DEPS='cuda boost eigen openmpi'
PYTHON_DEPS='scikit_build_core pyproject_metadata'
PRE_BUILD_COMMANDS='
	sed -i "s#../../../external_libs/fmt/include/##" include/LightGBM/utils/common.h;
	export CMAKE_ARGS="-DUSE_CUDA=1 -DUSE_MPI=ON -DBoost_NO_BOOST_CMAKE=ON";
'
