MODULE_BUILD_DEPS='tbb googletest'
PRE_BUILD_COMMANDS='export CMAKE_ARGS="-DMANIFOLD_PYBIND=ON -DMANIFOLD_CBIND=OFF -DMANIFOLD_PAR=TBB -DMANIFOLD_TEST=OFF -DBUILD_SHARED_LIBS=OFF"'