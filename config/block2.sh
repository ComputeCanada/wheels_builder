MODULE_BUILD_DEPS='flexiblas'
PRE_BUILD_COMMANDS='
	sed -i -e "s/-DUSE_MKL=ON/-DUSE_MKL=OFF/" -e "s/--jobs=2/--jobs=8/" -e "/mkl==/d" -e "/mkl-include/d" -e "/intel-openmp/d" -e "/pybind11/d" setup.py;
'
POST_BUILD_COMMANDS="$SCRIPT_DIR/manipulate_wheels.py --inplace --force --remove_req cmake -w $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)"
