#!/bin/env bash

if [[ -z "$PYTHON_VERSIONS" ]]; then
	PYTHON_VERSIONS="python/2.7 python/3.5 python/3.6"
fi

ALL_PACKAGES="nose numpy scipy Cython h5py matplotlib dateutil numexpr bottleneck pandas pyzmq qiime future pyqi bio-format cogent qiime-default-reference pynast burrito burrito-fillings gdata emperor qcli scikit-bio natsort click subprocess32 cycler python-dateutil dlib shapely affine rasterio numba llvmlite velocyto htseq mpi4py sympy mpmath blist paycheck lockfile deap arff cryptography paramiko pyparsing netifaces netaddr funcsigs mock pytz enum34 bitstring Cycler PyZMQ path.py pysqlite requests nbformat Pygments singledispatch certifi backports_abc tornado MarkupSafe Jinja2 jupyter_client functools32 jsonschema mistune ptyprocess terminado simplegeneric ipython_genutils pathlib2 pickleshare traitlets notebook jupyter_core ipykernel pexpect backports.shutil_get_terminal_size prompt_toolkit ipywidgets widgetsnbextension ipython iptest testpath cffi pycparser asn1crypto ipaddress pynacl pyasn1 bcrypt nbconvert entrypoints configparser pandocfilters dnspython pygame pyyaml fuel pillow pillow-simd olefile seaborn theano Amara bx-python python-lzo RSeQC xopen cutadapt cgat kiwisolver torchvision-cpu torchvision-gpu dask distributed arboretum netCDF4 mdtraj biom-format grpcio absl-py gast protobuf tensorboard astor Markdown metasv cvxpy cvxopt dill multiprocess scs fastcache toolz ecos CVXcanon CoffeeScript PyExecJS msmbuilder Qutip"

PACKAGE=${1?Missing package name}
VERSION=$2
PYTHON_IMPORT_NAME="$PACKAGE"
PACKAGE_FOLDER_NAME="$PACKAGE"
PACKAGE_DOWNLOAD_NAME="$PACKAGE"
RPATH_TO_ADD=""

if [[ -n "$VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE==$VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
fi

if [[ "$PACKAGE" == "numpy" ]]; then
	MODULE_DEPS="imkl"
	PYTHON_DEPS="nose pytest"
	PYTHON_TESTS="numpy.__config__.show(); numpy.test()"
elif [[ "$PACKAGE" == "qutip" ]]; then
	PYTHON_DEPS="Cython numpy scipy matplotlib"
elif [[ "$PACKAGE" == "msmbuilder" ]]; then
	PYTHON_DEPS="numpy scipy scikit-learn mdtraj pandas cython<0.28 cvxopt nose"
elif [[ "$PACKAGE" == "deepchem" ]]; then
	PYTHON_DEPS="numpy pandas rdkit"
elif [[ "$PACKAGE" == "ray" ]]; then
	if [[ -z "$VERSION" ]]; then
		VERSION="0.4.0"
	fi
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/ray-project/ray/archive/ray-$VERSION.tar.gz"
	MODULE_DEPS="gcc/5.4.0 qt/5.10.1"
	PYTHON_DEPS="numpy scipy cython"
	PACKAGE_FOLDER_NAME="ray-ray-*/python"
	PRE_BUILD_COMMANDS="pwd; sed -i -e 's/-DPARQUET_BUILD_TESTS=off/-DPARQUET_BUILD_TESTS=off -DCMAKE_SKIP_RPATH=ON -DCMAKE_SKIP_INSTALL_RPATH=ON/g' ../thirdparty/scripts/build_parquet.sh && sed -i -e 's/-DARROW_WITH_ZSTD=off/-DARROW_WITH_ZSTD=off  -DCMAKE_SKIP_RPATH=ON -DCMAKE_SKIP_INSTALL_RPATH=ON/g' ../thirdparty/scripts/build_arrow.sh"
elif [[ "$PACKAGE" == "scs" ]]; then
	PYTHON_DEPS="numpy scipy"
elif [[ "$PACKAGE" == "PyWavelets" ]]; then
	PYTHON_DEPS="numpy"
	PYTHON_IMPORT_NAME="pywt"
elif [[ "$PACKAGE" == "scikit-image" ]]; then
	PYTHON_DEPS="numpy cython scipy"
	PYTHON_IMPORT_NAME="skimage"
elif [[ "$PACKAGE" == "pygdal" ]]; then
	PYTHON_DEPS="numpy"
	MODULE_DEPS="gcc gdal"
elif [[ "$PACKAGE" == "keras-vis" ]]; then
	PYTHON_IMPORT_NAME="vis"
	PACKAGE_DOWNLOAD_NAME="keras_vis"
elif [[ "$PACKAGE" == "keras-applications" ]]; then
	PYTHON_IMPORT_NAME="keras.applications"
	PACKAGE_DOWNLOAD_NAME="Keras_Applications"
elif [[ "$PACKAGE" == "keras-preprocessing" ]]; then
	PYTHON_IMPORT_NAME="keras.preprocessing"
	PACKAGE_DOWNLOAD_NAME="Keras_Preprocessing"
elif [[ "$PACKAGE" == "absl-py" ]]; then
	PYTHON_IMPORT_NAME="absl"
elif [[ "$PACKAGE" == "CoffeeScript" ]]; then
	PYTHON_DEPS="PyExecJS"
elif [[ "$PACKAGE" == "PyExecJS" ]]; then
	PYTHON_IMPORT_NAME="execjs"
elif [[ "$PACKAGE" == "CVXcanon" ]]; then
	PYTHON_DEPS="numpy scipy"
elif [[ "$PACKAGE" == "ecos" ]]; then
	PYTHON_DEPS="numpy scipy"
elif [[ "$PACKAGE" == "cvxpy" ]]; then
	PYTHON_DEPS="numpy multiprocess scs fastcache scipy six toolz CVXcanon dill"
elif [[ "$PACKAGE" == "cvxopt" ]]; then
	MODULE_DEPS="suitesparse fftw imkl"
	PRE_BUILD_COMMANDS="export CVXOPT_LAPACK_LIB=mkl_rt; export CVXOPT_BLAS_LIB=mkl_rt; export CVXOPT_BLAS_LIB_DIR=$MKLROOT/lib; export CVXOPT_SUITESPARSE_LIB_DIR=$EBROOTSUITESPARSE/lib; export CVXOPT_SUITESPARSE_INC_DIR=$EBROOTSUITESPARSE/include; "
elif [[ "$PACKAGE" == "multiprocess" ]]; then
	PYTHON_DEPS="dill"
elif [[ "$PACKAGE" == "grpcio" ]]; then
	PYTHON_IMPORT_NAME="grpc"
elif [[ "$PACKAGE" == "metasv" ]]; then
	PYTHON_DEPS="cython pysam"
elif [[ "$PACKAGE" == "scipy" ]]; then
	MODULE_DEPS="imkl"
	PYTHON_DEPS="nose numpy pytest"
	PYTHON_TESTS="scipy.__config__.show(); scipy.test()"
elif [[ "$PACKAGE" == "mdtraj" ]]; then
	PYTHON_DEPS="cython numpy scipy pandas"
elif [[ "$PACKAGE" == "biom-format" ]]; then
	PYTHON_DEPS="scipy"
	PACKAGE_DOWNLOAD_NAME="biom_format"
elif [[ "$PACKAGE" == "netCDF4" ]]; then
	MODULE_DEPS="hdf5-mpi netcdf-mpi"
	PYTHON_DEPS="numpy Cython"
	PRE_BUILD_COMMANDS='module load mpi4py; export HDF5_DIR=$EBROOTHDF5; export NETCDF4_DIR=$EBROOTNETCDF'
	RPATH_TO_ADD="$EBROOTOPENMPI/lib"
elif [[ "$PACKAGE" == "arboretum" ]]; then
	PYTHON_DEPS="numpy scipy scikit-learn pandas dask distributed"
elif [[ "$PACKAGE" == "Cython" ]]; then
	MODULE_DEPS=""
	PYTHON_DEPS=""
elif [[ "$PACKAGE" == "cutadapt" ]]; then
	PYTHON_DEPS="xopen"
elif [[ "$PACKAGE" == "cgat" ]]; then
	PYTHON_IMPORT_NAME="cgat"
	PYTHON_DEPS="numpy cython pysam setuptools pyparsing pyaml alignlib-lite matplotlib biopython"
elif [[ "$PACKAGE" == "h5py" ]]; then
	MODULE_DEPS="hdf5"
	PYTHON_DEPS="nose numpy six Cython unittest2"
	PYTHON_TESTS="h5py.run_tests()"
elif [[ "$PACKAGE" == "matplotlib" ]]; then
	PYTHON_DEPS="pyparsing pytz six cycler python-dateutil numpy backports.functools-lru-cache kiwisolver"
elif [[ "$PACKAGE" == "python-dateutil" ]]; then
	PYTHON_IMPORT_NAME="dateutil"
elif [[ "$PACKAGE" == "numexpr" ]]; then
	PYTHON_DEPS="numpy"
	PYTHON_TESTS="numexpr.test()"
elif [[ "$PACKAGE" == "bottleneck" ]]; then
	PYTHON_DEPS="numpy nose"
	PYTHON_TESTS="bottleneck.test();" # bottleneck.bench()"
	PACKAGE_DOWNLOAD_NAME="Bottleneck"
	PACKAGE_FOLDER_NAME="Bottleneck"
elif [[ "$PACKAGE" == "tables" ]]; then
	MODULE_DEPS="hdf5"
	PYTHON_DEPS="h5py numpy numexpr six nose mock"
	PYTHON_TESTS="tables.test()"
elif [[ "$PACKAGE" == "bx-python" ]]; then
	PYTHON_DEPS="numpy python-lzo six"
	PYTHON_IMPORT_NAME="bx"
elif [[ "$PACKAGE" == "RSeQC" ]]; then
	PYTHON_DEPS="bx-python"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "pandas" ]]; then
	PYTHON_DEPS="numpy python-dateutil pytz Cython numexpr bottleneck scipy tables matplotlib nose pytest moto"
#	PYTHON_TESTS="pandas.test()"
elif [[ "$PACKAGE" == "pyzmq" ]]; then
	PYTHON_IMPORT_NAME="zmq"
elif [[ "$PACKAGE" == "qiime" ]]; then
	PYTHON_DEPS="numpy scipy matplotlib mock nose cycler decorator enum34 functools32 ipython matplotlib pexpect"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "dlib-cpu" ]]; then
	MODULE_DEPS="gcc/5.4.0 boost imkl"    # it does not work with Intel, and requires Boost
	PRE_BUILD_COMMANDS='sed -i -e "s;/opt/intel/mkl/lib/intel64;${MKLROOT}/lib/intel64;g" $(find . -name "cmake_find_blas.txt") '
	PYTHON_VERSIONS="python/2.7"
	PACKAGE="dlib"
	PYTHON_IMPORT_NAME="$PACKAGE"
	PACKAGE_FOLDER_NAME="$PACKAGE"
	PACKAGE_DOWNLOAD_NAME="$PACKAGE"
	PACKAGE_SUFFIX='-cpu'
elif [[ "$PACKAGE" == "dlib-gpu" ]]; then
	MODULE_DEPS="gcc/5.4.0 boost imkl cuda cudnn"    # it does not work with Intel, and requires Boost
	PRE_BUILD_COMMANDS='export CUDNN_HOME=$EBROOTCUDNN; sed -i -e "s;/opt/intel/mkl/lib/intel64;${MKLROOT}/lib/intel64;g" $(find . -name "cmake_find_blas.txt")'
	PYTHON_VERSIONS="python/2.7"
	PACKAGE="dlib"
	PYTHON_IMPORT_NAME="$PACKAGE"
	PACKAGE_FOLDER_NAME="$PACKAGE"
	PACKAGE_DOWNLOAD_NAME="$PACKAGE"
	PACKAGE_SUFFIX='-gpu'
elif [[ "$PACKAGE" == "shapely" ]]; then
	MODULE_DEPS="geos"
	# need to patch geos.py to find libgeos_c.so based on the module that was loaded at build time
	PRE_BUILD_COMMANDS='sed -i -e "s;os.path.join(sys.prefix, \"lib\", \"libgeos_c.so\"),;\"$EBROOTGEOS/lib/libgeos_c.so\",;g" $(find . -name "geos.py")'
	PACKAGE_FOLDER_NAME="Shapely"
	PACKAGE_DOWNLOAD_NAME="Shapely"
elif [[ "$PACKAGE" == "rasterio" ]]; then
	PYTHON_DEPS="numpy affine snuggs cligj click-plugins enum34"
	MODULE_DEPS="gdal"
elif [[ "$PACKAGE" == "numba" ]]; then
	if [[ "$VERSION" == "0.31.0" ]]; then
		PYTHON_DEPS="numpy enum34 llvmlite==0.16.0"
	else
		PYTHON_DEPS="numpy enum34 llvmlite"
	fi
elif [[ "$PACKAGE" == "llvmlite" ]]; then
	PYTHON_DEPS="enum34"
elif [[ "$PACKAGE" == "scikit-learn" ]]; then
	PYTHON_IMPORT_NAME="sklearn"
	PYTHON_DEPS="numpy scipy"
elif [[ "$PACKAGE" == "velocyto" ]]; then
	PYTHON_DEPS="numpy scipy cython llvmlite==0.16.0 numba==0.31.0 matplotlib scikit-learn h5py click loompy"
	PYTHON_VERSIONS="python/3.6"
	unset PYTHON_IMPORT_NAME
elif [[ "$PACKAGE" == "htseq" ]]; then
	PYTHON_DEPS="numpy Cython pysam"
	PACKAGE_FOLDER_NAME="HTSeq"
	PACKAGE_DOWNLOAD_NAME="HTSeq"
	PYTHON_IMPORT_NAME="HTSeq"
elif [[ "$PACKAGE" == "mpi4py" ]]; then
	MODULE_DEPS="openmpi"
elif [[ "$PACKAGE" == "pytorch-cpu" ]];then
	PACKAGE="pytorch"
	MODULE_DEPS="gcc/6.4.0 imkl/11.3.4.258"
	PYTHON_DEPS="pyyaml numpy typing"
	PRE_BUILD_COMMANDS="export MAX_JOBS=3; export MKL_ROOT=$MKLROOT; export MKL_LIBRARY=$MKLROOT/lib/intel64; export CMAKE_LIBRARY_PATH=$MKL_LIBRARY"
	PACKAGE_FOLDER_NAME="$PACKAGE"
	PACKAGE_DOWNLOAD_NAME="$PACKAGE"
	PACKAGE_SUFFIX='-cpu'
	PYTHON_IMPORT_NAME="torch"
elif [[ "$PACKAGE" == "pytorch-gpu" ]];then
	PACKAGE="pytorch"
	MODULE_DEPS="imkl/11.3.4.258 gcc/5.4.0 magma/2.2.0 cuda/8.0.44 cudnn/7.0 magma/2.2.0"
	PYTHON_DEPS="pyyaml numpy typing"
	PRE_BUILD_COMMANDS="export MAX_JOBS=3; export MKL_ROOT=$MKLROOT; export MKL_LIBRARY=$MKLROOT/lib/intel64; export LIBRARY_PATH=/cvmfs/soft.computecanada.ca/nix/lib/:$LIBRARY_PATH; export CMAKE_PREFIX_PATH=$EBROOTMAGMA; export CMAKE_LIBRARY_PATH=$MKL_LIBRARY"
	PACKAGE_FOLDER_NAME="$PACKAGE"
	PACKAGE_DOWNLOAD_NAME="$PACKAGE"
	PACKAGE_SUFFIX='-gpu'
	PYTHON_IMPORT_NAME="torch"
elif [[ "$PACKAGE" == "mpmath" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "preprocess" ]]; then
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "paycheck" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "bitstring" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "pandocfilters" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "Amara" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
	PYTHON_IMPORT_NAME="amara"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "pysqlite" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
	PYTHON_IMPORT_NAME="pysqlite2"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "python-lzo" ]]; then
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" -e "s;/usr/include;$NIXUSER_PROFILE/include;g" setup.py'
	PYTHON_IMPORT_NAME="lzo"
elif [[ "$PACKAGE" == "iptest" ]]; then
	PACKAGE_FOLDER_NAME="IPTest"
	PACKAGE_DOWNLOAD_NAME="IPTest"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "sympy" ]]; then
	PYTHON_DEPS="mpmath"
elif [[ "$PACKAGE" == "cffi" ]]; then
	PYTHON_DEPS="pycparser"
elif [[ "$PACKAGE" == "ipaddress" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "pynacl" ]]; then
	PACKAGE_FOLDER_NAME="PyNaCl"
	PACKAGE_DOWNLOAD_NAME="PyNaCl"
	PYTHON_IMPORT_NAME="nacl"
elif [[ "$PACKAGE" == "functools32" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "MarkupSafe" ]]; then
	PYTHON_IMPORT_NAME="markupsafe"
elif [[ "$PACKAGE" == "pygame" ]]; then
	PRE_BUILD_COMMANDS="export LOCALBASE=$NIXUSER_PROFILE"
elif [[ "$PACKAGE" == "pyyaml" ]]; then
	PACKAGE_FOLDER_NAME="PyYAML"
	PACKAGE_DOWNLOAD_NAME="PyYAML"
	PYTHON_IMPORT_NAME="yaml"
elif [[ "$PACKAGE" == "pillow" ]]; then
	PYTHON_DEPS="olefile"
	PACKAGE_FOLDER_NAME="Pillow"
	PACKAGE_DOWNLOAD_NAME="Pillow"
	PYTHON_IMPORT_NAME="PIL"
elif [[ "$PACKAGE" == "pillow-simd" ]]; then
	PACKAGE_FOLDER_NAME="Pillow-SIMD"
	PACKAGE_DOWNLOAD_NAME="Pillow-SIMD"
	PRE_BUILD_COMMANDS="export CC=\"cc -mavx2\""
	PYTHON_IMPORT_NAME="PIL"
elif [[ "$PACKAGE" == "olefile" ]]; then
	# need to patch it so it supports bdist_wheel
	PRE_BUILD_COMMANDS='sed -i -e "s/distutils.core/setuptools/g" setup.py'
elif [[ "$PACKAGE" == "fuel" ]]; then
	PYTHON_DEPS="numpy six picklable_itertools pyyaml h5py tables progressbar2 pyzmq scipy pillow numexpr"
elif [[ "$PACKAGE" == "seaborn" ]]; then
	PYTHON_DEPS="numpy scipy matplotlib pandas"
elif [[ "$PACKAGE" == "backports.functools-lru-cache" ]]; then
	PYTHON_IMPORT_NAME="backports.functools_lru_cache"
elif [[ "$PACKAGE" == "theano" ]]; then
	PACKAGE_FOLDER_NAME="Theano"
	PACKAGE_DOWNLOAD_NAME="Theano"
	PYTHON_DEPS="numpy scipy six"
elif [[ "$PACKAGE" == "alignlib-lite" ]]; then
	MODULE_DEPS="boost"
elif [[ "$PACKAGE" == "torchvision-cpu" ]]; then
	PYTHON_DEPS="numpy pillow-simd torch-cpu"
	PACKAGE_SUFFIX="-cpu"
elif [[ "$PACKAGE" == "torchvision-gpu" ]]; then
	PYTHON_DEPS="numpy pillow-simd torch-gpu"
	PACKAGE_SUFFIX="-gpu"
elif [[ "$PACKAGE" == "Pillow" ]]; then
	PYTHON_IMPORT_NAME="PIL"
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
	mkdir $PVDIR
	if [[ $PACKAGE == "pytorch" ]];then
		pushd $PVDIR
		git clone https://github.com/pytorch/pytorch
		pushd $PACKAGE_FOLDER_NAME*
		if [[ -n "$VERSION" ]]; then
			git checkout -b v$VERSION
		fi
		git submodule update --init
	else
		pip download --no-binary --no-deps $PACKAGE_DOWNLOAD_ARGUMENT
		ARCHNAME=$(ls $PACKAGE_DOWNLOAD_NAME-[0-9]*{.zip,.tar.gz,.whl})
		# skip packages that are already in whl format
		if [[ $ARCHNAME == *.whl ]]; then
			cp $ARCHNAME ..
			continue
		fi
		unzip $ARCHNAME -d $PVDIR || tar xfv $ARCHNAME -C $PVDIR
		pushd $PVDIR
		pushd $PACKAGE_FOLDER_NAME*
	fi
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
		if [[ $PACKAGE == "pytorch" ]];then
		sed -i -e "s/name=\"torch\"/name=\"torch$PACKAGE_SUFFIX\"/g" setup.py
		else
		sed -i -e "s/name='$PACKAGE'/name='$PACKAGE$PACKAGE_SUFFIX'/g" $(find . -name "setup.py")
		fi
	fi
	$PYTHON_CMD setup.py bdist_wheel > build.log
	pushd dist
	WHEEL_NAME=$(ls *.whl)
	if [[ -n "$RPATH_TO_ADD" ]]; then
		echo "Running /cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path=$RPATH_TO_ADD --any_interpreter"
		/cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path $RPATH_TO_ADD --any_interpreter
	fi
	pwd
	ls
	echo cp $WHEEL_NAME ../../../..
	cp $WHEEL_NAME ../../../..
	popd
	popd
	popd

	echo "Testing..."
	if [[ -n "$MODULE_DEPS" ]]; then
		module unload $MODULE_DEPS
	fi
	module list
	pip install ../$WHEEL_NAME --no-index --no-cache
	if [[ -n "$PYTHON_IMPORT_NAME" ]]; then
		$PYTHON_CMD -c "import $PYTHON_IMPORT_NAME; $PYTHON_TESTS"
	fi
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
echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/[generic,avx2,avx,sse3] and synchronize CVMFS"
