#!/bin/env bash

PYTHON_VERSIONS="python/2.7.13 python/3.5.2"

ALL_PACKAGES="nose numpy scipy Cython h5py matplotlib dateutil numexpr bottleneck pandas pyzmq qiime future pyqi bio-format cogent qiime-default-reference pynast burrito burrito-fillings gdata emperor qcli scikit-bio natsort click subprocess32 cycler python-dateutil dlib shapely affine rasterio"

PACKAGE=$1
PYTHON_IMPORT_NAME="$PACKAGE"
PACKAGE_FOLDER_NAME="$PACKAGE"
if [[ "$PACKAGE" == "numpy" ]]; then
	MODULE_DEPS="imkl"
	PYTHON_DEPS="nose"
	PYTHON_TESTS="numpy.__config__.show(); numpy.test()"
elif [[ "$PACKAGE" == "scipy" ]]; then
	MODULE_DEPS="imkl"
	PYTHON_DEPS="nose numpy"
	PYTHON_TESTS="scipy.__config__.show(); scipy.test()"
elif [[ "$PACKAGE" == "Cython" ]]; then
	MODULE_DEPS=""
	PYTHON_DEPS=""
elif [[ "$PACKAGE" == "h5py" ]]; then
	MODULE_DEPS="hdf5"
	PYTHON_DEPS="nose numpy six Cython"
	PYTHON_TESTS="h5py.run_tests()"
	PRE_BUILD_COMMANDS="export HDF5_DIR=$(dirname $(dirname $(which h5dump)))"
elif [[ "$PACKAGE" == "matplotlib" ]]; then
	PYTHON_DEPS="pyparsing pytz six cycler python-dateutil numpy"
elif [[ "$PACKAGE" == "python-dateutil" ]]; then
	PYTHON_IMPORT_NAME="dateutil"
elif [[ "$PACKAGE" == "numexpr" ]]; then
	PYTHON_DEPS="numpy"
	PYTHON_TESTS="numexpr.test()"
elif [[ "$PACKAGE" == "bottleneck" ]]; then
	PYTHON_DEPS="numpy nose"
	PYTHON_TESTS="bottleneck.test(); bottleneck.bench()"
	PACKAGE_FOLDER_NAME="Bottleneck"
elif [[ "$PACKAGE" == "tables" ]]; then
	MODULE_DEPS="hdf5"
	PYTHON_DEPS="h5py numpy numexpr six nose mock"
	PYTHON_TESTS="tables.test()"
elif [[ "$PACKAGE" == "pandas" ]]; then
	PYTHON_DEPS="numpy python-dateutil pytz Cython numexpr bottleneck scipy tables matplotlib nose pytest"
	PYTHON_TESTS="pandas.test()"
elif [[ "$PACKAGE" == "pyzmq" ]]; then
	PYTHON_IMPORT_NAME="zmq"
elif [[ "$PACKAGE" == "qiime" ]]; then
	PYTHON_DEPS="numpy scipy matplotlib mock nose cycler decorator enum34 functools32 ipython matplotlib pexpect"
	PYTHON_VERSIONS="python/2.7.13"
elif [[ "$PACKAGE" == "dlib-cpu" ]]; then
	MODULE_DEPS="gcc/5.4.0 boost imkl"    # it does not work with Intel, and requires Boost
	PRE_BUILD_COMMANDS='sed -i -e "s;/opt/intel/mkl/lib/intel64;${MKLROOT}/lib/intel64;g" $(find . -name "cmake_find_blas.txt") '
	PYTHON_VERSIONS="python/2.7.13"
	PACKAGE="dlib"
	PYTHON_IMPORT_NAME="$PACKAGE"
	PACKAGE_FOLDER_NAME="$PACKAGE"
	PACKAGE_SUFFIX='-cpu'
elif [[ "$PACKAGE" == "dlib-gpu" ]]; then
	MODULE_DEPS="gcc/5.4.0 boost imkl cuda cudnn"    # it does not work with Intel, and requires Boost
	PRE_BUILD_COMMANDS='export CUDNN_HOME=$EBROOTCUDNN; sed -i -e "s;/opt/intel/mkl/lib/intel64;${MKLROOT}/lib/intel64;g" $(find . -name "cmake_find_blas.txt")'
	PYTHON_VERSIONS="python/2.7.13"
	PACKAGE="dlib"
	PYTHON_IMPORT_NAME="$PACKAGE"
	PACKAGE_FOLDER_NAME="$PACKAGE"
	PACKAGE_SUFFIX='-gpu'
elif [[ "$PACKAGE" == "shapely" ]]; then
	MODULE_DEPS="geos"
	# need to patch geos.py to find libgeos_c.so based on the module that was loaded at build time
	PRE_BUILD_COMMANDS='sed -i -e "s;os.path.join(sys.prefix, \"lib\", \"libgeos_c.so\"),;\"$EBROOTGEOS/lib/libgeos_c.so\",;g" $(find . -name "geos.py")'
	PACKAGE_FOLDER_NAME="Shapely"
elif [[ "$PACKAGE" == "rasterio" ]]; then
	PYTHON_DEPS="numpy affine snuggs cligj click-plugins enum34"
	MODULE_DEPS="gdal"
fi


DIR=tmp.$$
mkdir $DIR
pushd $DIR
for pv in $PYTHON_VERSIONS; do
	if [[ -n "$MODULE_DEPS" ]]; then
		module load $MODULE_DEPS
	fi
	module load $pv

	if [[ $pv =~ python/2 ]]; then
		PYTHON_CMD=python2
	else
		PYTHON_CMD=python3
	fi
	PVDIR=${pv//\//-}

	echo "Setting up build environment"
	virtualenv build_$PVDIR || pyvenv build_$PVDIR
	source build_$PVDIR/bin/activate
	if [[ -n "$PYTHON_DEPS" ]]; then
		pip install $PYTHON_DEPS
	fi
	pip freeze

	echo "Downloading source"
	pip download --no-binary --no-deps $PACKAGE
	ARCHNAME=$(ls $PACKAGE_FOLDER_NAME-[0-9]*)
	mkdir $PVDIR
	unzip $ARCHNAME -d $PVDIR || tar xfv $ARCHNAME -C $PVDIR
	pushd $PVDIR/$PACKAGE_FOLDER_NAME*

	echo "Building"
	pwd
	ls
	module list
	which $PYTHON_CMD
	if [[ "$PACKAGE" == "numpy" ]]; then
		cat << EOF > site.cfg
[mkl]
library_dirs = $MKLROOT/lib/intel64
include_dirs = $MKLROOT/include
mkl_libs = mkl_rt
lapack_libs =
EOF
	fi
	eval $PRE_BUILD_COMMANDS
	# change the name of the wheel to add a suffix
	if [[ -n "$PACKAGE_SUFFIX" ]]; then
		sed -i -e "s/name='$PACKAGE'/name='$PACKAGE$PACKAGE_SUFFIX'/g" $(find . -name "setup.py")
	fi
	$PYTHON_CMD setup.py bdist_wheel > build.log
	pushd dist
	WHEEL_NAME=$(ls *.whl)
	pwd
	ls
	echo cp $WHEEL_NAME ../../../..
	cp $WHEEL_NAME ../../../..
	popd
	popd

	echo "Testing..."
	if [[ -n "$MODULE_DEPS" ]]; then
		module unload $MODULE_DEPS
	fi
	module list
	pip install ../$WHEEL_NAME --no-index --no-cache
	$PYTHON_CMD -c "import $PYTHON_IMPORT_NAME; $PYTHON_TESTS"
	SUCCESS=$?
	deactivate
	if [[ $SUCCESS -ne 0 ]]; then
		echo "Error happened"
		cd ..
		exit $SUCCESS
	fi
done

popd

echo "Build done, you can now remove $DIR"
echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/[generic,avx2,avx] and synchronize CVMFS"

