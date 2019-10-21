#!/bin/env bash

if [[ -z "$PYTHON_VERSIONS" ]]; then
	PYTHON_VERSIONS=$(ls -1d /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/3* | grep -Po "\d\.\d" | sort -u | sed 's#^#python/#')
fi

PACKAGE=${1?Missing package name}
VERSION=$2
PYTHON_IMPORT_NAME="$PACKAGE"
PACKAGE_FOLDER_NAME="$PACKAGE"
PACKAGE_DOWNLOAD_NAME="$PACKAGE"
RPATH_TO_ADD=""
BDIST_WHEEL_ARGS=""
PRE_DOWNLOAD_COMMANDS=""
TMP_WHEELHOUSE=$(pwd)
PATCHES=""
# Make sure $PACKAGE_DOWNLOAD_ARGUMENT is not expanded right away
# Do not collect binaries and don't install dependencies
PACKAGE_DOWNLOAD_CMD="pip download --no-binary \$PACKAGE_DOWNLOAD_ARGUMENT --no-deps \$PACKAGE_DOWNLOAD_ARGUMENT"

PRE_BUILD_COMMANDS_DEFAULT='sed -i -e "s/distutils.core/setuptools/g" setup.py'
PYTHON_DEPS="numpy scipy cython"

if [[ -n "$VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE==$VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
fi

if [[ "$PACKAGE" == "numpy" ]]; then
	MODULE_BUILD_DEPS="imkl/2019.2.187"
	PYTHON_DEPS="nose pytest"
	PYTHON_TESTS="numpy.__config__.show(); numpy.test()"
elif [[ "$PACKAGE" == "umap-learn" ]]; then
	PYTHON_IMPORT_NAME="umap"
elif [[ "$PACKAGE" == "PyOpenGL" ]]; then
	PYTHON_TESTS="from OpenGL.GL.ARB.shader_objects import *; from OpenGL.GL.ARB.fragment_shader import *; from OpenGL.GL.ARB.vertex_shader import *; from OpenGL.GL import *; from OpenGL.GLU import *"
elif [[ "$PACKAGE" == "msprime" ]]; then
	MODULE_BUILD_DEPS="intel/2016.4 imkl/2019.2.187 gsl/1.16"
	RPATH_TO_ADD="$EBROOTIMKL/lib/intel64"
elif [[ "$PACKAGE" == "Box2D-kengz" ]]; then
	PYTHON_IMPORT_NAME="Box2D"
elif [[ "$PACKAGE" == "pyslurm" ]]; then
	PRE_BUILD_COMMANDS='sed -i -e "s;SLURM_INC = \"\";SLURM_INC = \"/opt/software/slurm/include/include\";g" -e "s;SLURM_LIB = \"\";SLURM_LIB = \"/opt/software/slurm/lib\";g" setup.py'
elif [[ "$PACKAGE" == "cogent" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "amico" ]]; then
	PYTHON_DEPS="numpy dipy scipy nibabel h5py six"
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/daducci/AMICO/archive/master.zip"
	PACKAGE_DOWNLOAD_NAME="master.zip"
	PACKAGE_FOLDER_NAME="AMICO-master"
elif [[ "$PACKAGE" == "protobuf" ]]; then
	PYTHON_IMPORT_NAME="google.protobuf"
elif [[ "$PACKAGE" == "multipledispatch" ]]; then
	PYTHON_DEPS="six"
elif [[ "$PACKAGE" == "dask-ml" ]]; then
	MODULE_BUILD_DEPS="llvm/6.0.1"
elif [[ "$PACKAGE" == "anvio" ]]; then
	PYTHON_DEPS="numpy Cython statsmodels==0.9.0"
	MODULE_BUILD_DEPS="gcc/5.4.0 gsl/2.3"
elif [[ "$PACKAGE" == "OBITools" ]]; then
	PYTHON_DEPS="Cython Sphinx ipython virtualenv"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "gdata" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "scikit-bio" ]]; then
	PYTHON_DEPS="numpy natsort"
elif [[ "$PACKAGE" == "qcli" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "emperor" ]]; then
	PYTHON_DEPS="qcli"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "pynast" ]]; then
	PYTHON_DEPS="cogent>=1.5.3 numpy"
elif [[ "$PACKAGE" == "qutip" ]]; then
	PYTHON_DEPS="Cython numpy scipy matplotlib"
elif [[ "$PACKAGE" == "msmbuilder" ]]; then
	PYTHON_DEPS="numpy scipy scikit-learn mdtraj pandas cython<0.28 cvxopt nose"
elif [[ "$PACKAGE" == "openslide-python" ]]; then
	MODULE_BUILD_DEPS="intel/2016.4 openslide"
	PRE_BUILD_COMMANDS='sed -i -e "/import sys/a import os" -e "s;.libopenslide.so.0.;os.environ.get(\"EBROOTOPENSLIDE\",\"$EBROOTOPENSLIDE\") + \"/lib/libopenslide.so.0\";g" $(find . -name "lowlevel.py")'
elif [[ "$PACKAGE" == "cupy" ]]; then
	PYTHON_DEPS="numpy fastrlock"
	MODULE_BUILD_DEPS="gcc/7.3.0 cuda/10 cudnn nccl"
	# needed otherwise it does not find libcuda.so
	PRE_DOWNLOAD_COMMANDS='export LDFLAGS="-L$EBROOTCUDA/lib64/stubs -L$EBROOTNCCL/lib" ; export CFLAGS="-I$EBROOTNCCL/include/"'
	# libnvrtc must find at runtime libnvrtc-builtins, either patch libnvrtc runpath or add DT_NEEDED
	current_py_version=${EBVERSIONPYTHON::-2}
	current_nvrtc_lib="cupy/cuda/nvrtc.cpython-${current_py_version//.}m-x86_64-linux-gnu.so"
	PATCH_WHEEL_COMMANDS="unzip \$ARCHNAME $current_nvrtc_lib && patchelf --add-needed libnvrtc-builtins.so $current_nvrtc_lib && zip \$ARCHNAME $current_nvrtc_lib"
	POST_BUILD_COMMANDS=${PATCH_WHEEL_COMMANDS//ARCHNAME/WHEEL_NAME}
elif [[ "$PACKAGE" == "chainer" ]]; then
	PYTHON_DEPS="filelock"
elif [[ "$PACKAGE" == "chainermn" ]]; then
	PYTHON_DEPS="chainer"
	PRE_BUILD_COMMANDS='module load mpi4py'
elif [[ "$PACKAGE" == "deepchem" ]]; then
	PYTHON_DEPS="numpy pandas joblib scikit-learn tensorflow_gpu pillow simdna"
	MODULE_RUNTIME_DEPS="gcc/5.4.0 rdkit/2018.03.3"
elif [[ "$PACKAGE" == "ray" ]]; then
	if [[ -z "$VERSION" ]]; then
		VERSION="0.4.0"
	fi
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/ray-project/ray/archive/ray-$VERSION.tar.gz"
	MODULE_BUILD_DEPS="gcc/5.4.0 qt/5.10.1"
	if [[ "$VERSION" == 0.7.0 ]]; then
		MODULE_BUILD_DEPS="gcc/7.3.0 bazel/0.19.2 qt/5.10.1"
	fi
	PYTHON_DEPS="numpy scipy cython"
	PACKAGE_FOLDER_NAME="ray-ray-*/python"
	PRE_BUILD_COMMANDS="pwd; sed -i -e 's/-DPARQUET_BUILD_TESTS=off/-DPARQUET_BUILD_TESTS=off -DCMAKE_SKIP_RPATH=ON -DCMAKE_SKIP_INSTALL_RPATH=ON/g' ../thirdparty/scripts/build_parquet.sh && sed -i -e 's/-DARROW_WITH_ZSTD=off/-DARROW_WITH_ZSTD=off  -DCMAKE_SKIP_RPATH=ON -DCMAKE_SKIP_INSTALL_RPATH=ON/g' ../thirdparty/scripts/build_arrow.sh"
elif [[ "$PACKAGE" == "MinkowskiEngine" ]]; then
	PYTHON_VERSIONS="python/3.6 python/3.7"
	MODULE_BUILD_DEPS="cuda/10 imkl"
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/StanfordVL/MinkowskiEngine/archive/master.zip"
	PACKAGE_DOWNLOAD_NAME="master.zip"
	PRE_BUILD_COMMANDS='sed -i -e "s/make /make BLAS=mkl /g" -e "s/, .openblas.//g" $(find . -name "setup.py")'
	PYTHON_DEPS="torch"
elif [[ "$PACKAGE" == "PyWavelets" ]]; then
	PYTHON_IMPORT_NAME="pywt"
elif [[ "$PACKAGE" == "pygdal" ]]; then
	MODULE_BUILD_DEPS="gcc gdal"
elif [[ "$PACKAGE" == "keras-vis" ]]; then
	PYTHON_IMPORT_NAME="vis"
	PACKAGE_DOWNLOAD_NAME="keras_vis"
elif [[ "$PACKAGE" == "Keras_Applications" ]]; then
	PYTHON_DEPS="keras tensorflow_gpu"
elif [[ "$PACKAGE" == "Keras_Preprocessing" ]]; then
	PYTHON_DEPS="keras tensorflow_gpu"
elif [[ "$PACKAGE" == "CoffeeScript" ]]; then
	PYTHON_DEPS="PyExecJS"
elif [[ "$PACKAGE" == "cvxpy" ]]; then
	PYTHON_DEPS="numpy multiprocess scs fastcache scipy six toolz CVXcanon dill"
elif [[ "$PACKAGE" == "cvxopt" ]]; then
	MODULE_BUILD_DEPS="gcc suitesparse fftw imkl"
	PRE_BUILD_COMMANDS="export CVXOPT_LAPACK_LIB=mkl_rt; export CVXOPT_BLAS_LIB=mkl_rt; export CVXOPT_BLAS_LIB_DIR=$MKLROOT/lib; export CVXOPT_SUITESPARSE_LIB_DIR=$EBROOTSUITESPARSE/lib; export CVXOPT_SUITESPARSE_INC_DIR=$EBROOTSUITESPARSE/include; export CVXOPT_BUILD_FFTW=1; export CVXOPT_FFTW_LIB_DIR=$EBROOTFFTW/lib; export  CVXOPT_FFTW_INC_DIR=$EBROOTFFTW/include; "
elif [[ "$PACKAGE" == "multiprocess" ]]; then
	PYTHON_DEPS="dill"
elif [[ "$PACKAGE" == "grpcio" ]]; then
	PYTHON_IMPORT_NAME="grpc"
elif [[ "$PACKAGE" == "metasv" ]]; then
	PYTHON_DEPS="cython pysam"
elif [[ "$PACKAGE" == "scipy" ]]; then
	MODULE_BUILD_DEPS="imkl/2018.3.222"
	PYTHON_DEPS="nose numpy pytest"
	PYTHON_TESTS="scipy.__config__.show(); scipy.test()"
elif [[ "$PACKAGE" == "mdtraj" ]]; then
	PYTHON_DEPS="cython numpy scipy pandas"
elif [[ "$PACKAGE" == "netCDF4" ]]; then
	MODULE_BUILD_DEPS="gcc openmpi hdf5-mpi netcdf-mpi"
	PRE_BUILD_COMMANDS='module load mpi4py; export HDF5_DIR=$EBROOTHDF5; export NETCDF4_DIR=$EBROOTNETCDF'
	RPATH_TO_ADD="$EBROOTOPENMPI/lib"
elif [[ "$PACKAGE" == "arboretum" ]]; then
	PYTHON_DEPS="numpy scipy scikit-learn pandas dask distributed"
elif [[ "$PACKAGE" == "Cython" ]]; then
	MODULE_BUILD_DEPS=""
	PYTHON_DEPS=""
elif [[ "$PACKAGE" == "cutadapt" ]]; then
	PYTHON_DEPS="xopen"
elif [[ "$PACKAGE" == "cgat" ]]; then
	PYTHON_DEPS="numpy cython pysam setuptools pyparsing pyaml alignlib-lite matplotlib biopython"
elif [[ "$PACKAGE" == "h5py" ]]; then
	if [[ "$RSNT_ARCH" == "avx" ]]; then
		MODULE_BUILD_DEPS="gcc/5.4.0 hdf5"
	else
		MODULE_BUILD_DEPS="gcc/7.3.0 hdf5"
	fi
	PYTHON_DEPS="nose numpy six Cython unittest2"
	PYTHON_TESTS="h5py.run_tests()"
elif [[ "$PACKAGE" == "matplotlib" ]]; then
	PYTHON_DEPS="pyparsing pytz six cycler python-dateutil numpy backports.functools-lru-cache kiwisolver"
elif [[ "$PACKAGE" == "numexpr" ]]; then
	PYTHON_TESTS="numexpr.test()"
elif [[ "$PACKAGE" == "Bottleneck" ]]; then
	PYTHON_DEPS="numpy nose"
	PYTHON_TESTS="bottleneck.test();" # bottleneck.bench()"
elif [[ "$PACKAGE" == "tables" ]]; then
	MODULE_BUILD_DEPS="gcc hdf5"
	PYTHON_DEPS="h5py numpy numexpr six nose mock"
	PYTHON_TESTS="tables.test()"
elif [[ "$PACKAGE" == "bx-python" ]]; then
	PYTHON_DEPS="numpy python-lzo six"
elif [[ "$PACKAGE" == "RSeQC" ]]; then
	PYTHON_DEPS="bx-python"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "pandas" ]]; then
	PYTHON_DEPS="numpy python-dateutil pytz Cython numexpr bottleneck scipy tables matplotlib nose pytest moto"
#	PYTHON_TESTS="pandas.test()"
elif [[ "$PACKAGE" == "pyzmq" ]]; then
	MODULE_BUILD_DEPS="zeromq"
elif [[ "$PACKAGE" == "qiime" ]]; then
	PYTHON_DEPS="numpy scipy matplotlib mock nose cycler decorator enum34 functools32 ipython matplotlib pexpect emperor qcli natsort<4.0.0"
elif [[ "$PACKAGE" == "dlib-cpu" ]]; then
	MODULE_BUILD_DEPS="gcc/7.3.0 boost imkl"    # it does not work with Intel, and requires Boost
	PRE_BUILD_COMMANDS='sed -i -e "s;/opt/intel/mkl/lib/intel64;${MKLROOT}/lib/intel64;g" $(find . -name "*find_blas.*") '
	PACKAGE="dlib"
	PYTHON_IMPORT_NAME="$PACKAGE"
	PACKAGE_FOLDER_NAME="$PACKAGE"
	PACKAGE_DOWNLOAD_NAME="$PACKAGE"
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
	PACKAGE_SUFFIX='-cpu'
	BDIST_WHEEL_ARGS='--yes CMAKE_SKIP_RPATH'
elif [[ "$PACKAGE" == "dlib-gpu" ]]; then
	MODULE_BUILD_DEPS="gcc/7.3.0 boost imkl cuda cudnn"    # it does not work with Intel, and requires Boost
	PRE_BUILD_COMMANDS='export CUDNN_HOME=$EBROOTCUDNN; sed -i -e "s;/opt/intel/mkl/lib/intel64;${MKLROOT}/lib/intel64;g" $(find . -name "*find_blas.*")'
	PACKAGE="dlib"
	PYTHON_IMPORT_NAME="$PACKAGE"
	PACKAGE_FOLDER_NAME="$PACKAGE"
	PACKAGE_DOWNLOAD_NAME="$PACKAGE"
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
	PACKAGE_SUFFIX='-gpu'
	BDIST_WHEEL_ARGS='--yes CMAKE_SKIP_RPATH'
elif [[ "$PACKAGE" == "shapely" ]]; then
	if [[ "$RSNT_ARCH" == "avx" ]]; then
		MODULE_BUILD_DEPS="gcc/5.4.0 geos"
	else
		MODULE_BUILD_DEPS="gcc geos"
	fi
	# need to patch geos.py to find libgeos_c.so based on the module that was loaded at build time
	PRE_BUILD_COMMANDS='sed -i -e "s;os.path.join(sys.prefix, \"lib\", \"libgeos_c.so\"),;\"$EBROOTGEOS/lib/libgeos_c.so\",;g" $(find . -name "geos.py")'
	PACKAGE_FOLDER_NAME="Shapely"
	PACKAGE_DOWNLOAD_NAME="Shapely"
elif [[ "$PACKAGE" == "rasterio" ]]; then
	PYTHON_DEPS="numpy affine snuggs cligj click-plugins enum34"
	MODULE_BUILD_DEPS="gcc gdal"
elif [[ "$PACKAGE" == "numba" ]]; then
	if [[ "$VERSION" == "0.31.0" ]]; then
		PYTHON_DEPS="numpy enum34 llvmlite==0.16.0"
	else
		PYTHON_DEPS="numpy enum34 llvmlite"
	fi
elif [[ "$PACKAGE" == "roboschool" ]]; then
	MODULE_BUILD_DEPS="gcc/7.3.0 boost bullet qt/5.6.1"
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/openai/roboschool/archive/1.0.46.tar.gz"
	PACKAGE_DOWNLOAD_NAME="1.0.46.tar.gz"
	PACKAGE_FOLDER_NAME="roboschool-1.0.46"
	PRE_BUILD_COMMANDS="pushd roboschool/cpp-household && make && popd "
	if [[ "$RSNT_ARCH" == "avx2" ]]; then
		export CFLAGS="-march=core-avx2"
	elif [[ "$RSNT_ARCH" == "avx512" ]]; then
		export CFLAGS="-march=skylake-avx512"
	fi
	PATCHES="$PWD/patches/roboschool-cpp-household.patch"
elif [[ "$PACKAGE" == "llvmlite" ]]; then
	PYTHON_DEPS="enum34"
	MODULE_BUILD_DEPS="llvm cuda/10 tbb"
	PATCHES="$PWD/patches/llvmlite-0.28.0-fpic.patch"
elif [[ "$PACKAGE" == "scikit-multilearn" ]]; then
	PYTHON_DEPS="numpy scipy Cython scikit-learn liac-arff requests networkx python-louvain"
elif [[ "$PACKAGE" == "liac-arff" ]]; then
	PYTHON_IMPORT_NAME="arff"
elif [[ "$PACKAGE" == "velocyto" ]]; then
	PYTHON_DEPS="numpy scipy cython numba matplotlib scikit-learn h5py loompy pysam Click pandas"
	PYTHON_VERSIONS="python/3.6 python/3.7"
elif [[ "$PACKAGE" == "HTSeq" ]]; then
	PYTHON_DEPS="numpy Cython pysam"
elif [[ "$PACKAGE" == "mpi4py" ]]; then
	MODULE_BUILD_DEPS="intel openmpi"
elif [[ "$PACKAGE" == "preprocess" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "Amara" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "pysqlite" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "IPTest" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "sympy" ]]; then
	PYTHON_DEPS="mpmath"
elif [[ "$PACKAGE" == "cffi" ]]; then
	PYTHON_DEPS="pycparser"
elif [[ "$PACKAGE" == "ipaddress" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "functools32" ]]; then
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "pygame" ]]; then
	MODULE_BUILD_DEPS="sdl2"
	PRE_BUILD_COMMANDS="export LOCALBASE=$NIXUSER_PROFILE"
elif [[ "$PACKAGE" == "pillow" || "$PACKAGE" == "Pillow" ]]; then
	PYTHON_DEPS="olefile"
	PACKAGE_FOLDER_NAME="Pillow"
	PACKAGE_DOWNLOAD_NAME="Pillow"
	PYTHON_IMPORT_NAME="PIL"
elif [[ "$PACKAGE" == "pillow-simd" ]]; then
	PACKAGE_FOLDER_NAME="Pillow-SIMD"
	PACKAGE_DOWNLOAD_NAME="Pillow-SIMD"
	PRE_BUILD_COMMANDS="export CC=\"cc -mavx2\""
	PYTHON_IMPORT_NAME="PIL"
elif [[ "$PACKAGE" == "fuel" ]]; then
	PYTHON_DEPS="numpy six picklable_itertools pyyaml h5py tables progressbar2 pyzmq scipy pillow numexpr"
elif [[ "$PACKAGE" == "seaborn" ]]; then
	PYTHON_DEPS="numpy scipy matplotlib pandas"
elif [[ "$PACKAGE" == "Theano" ]]; then
	PYTHON_DEPS="numpy scipy six"
elif [[ "$PACKAGE" == "alignlib-lite" ]]; then
	MODULE_BUILD_DEPS="boost"
elif [[ "$PACKAGE" == "torchvision" ]]; then
	# torch_cpu is only for testing purposes. It is not in torchvision requirements.
	# torchvision should be installed along with : torch-[cg]pu
	PYTHON_DEPS="numpy six pillow-simd torch-cpu"

	# Remove torch requirements from wheel as the user need to either install torch-[cg]pu wheel
	# Otherwise, it does not install because torchvision has a `torch` requirement, and no pypi version is supplied, thus failing.
	PATCH_WHEEL_COMMANDS="unzip -o \$ARCHNAME && sed -i -e 's/Requires-Dist: torch//' torchvision-*.dist-info/METADATA; sed -i -e 's/, \"torch\"//' torchvision-*.dist-info/metadata.json && zip -u \$ARCHNAME -r $PACKAGE $PACKAGE-*.dist-info"
elif [[ "$PACKAGE" == "torchtext" ]]; then
	# torch_cpu, six and numpy are only for testing purposes. They are not in torchtext requirements.
	# torchtext should be installed along with : numpy, six, torch-[cg]pu
	PYTHON_DEPS="certifi urllib3 chardet idna requests tqdm six numpy torch_cpu"

	# Remove torch requirements as the user need to either install torch-[cg]pu wheel and not PyPI torch.
	# Remove egg-info artefact as we are rebuilding a wheel.
	PRE_BUILD_COMMANDS="sed -i -e \"s/'torch',//g\" setup.py; rm -r torchtext.egg-info;"
elif [[ "$PACKAGE" == "wxPython" ]]; then
	MODULE_BUILD_DEPS="gtk+3/3.20.9"
	PYTHON_DEPS="six typing PyPubSub"
	PRE_BUILD_COMMANDS='export LDFLAGS=-Wl,-rpath,\$ORIGIN,-rpath,$EBROOTGTKPLUS3/lib'
elif [[ "$PACKAGE" == "smart_open" ]]; then
	PYTHON_DEPS="boto>=2.32 bz2file requests boto3"
elif [[ "$PACKAGE" == "gensim" ]]; then
	PYTHON_DEPS="numpy>=1.11.3 scipy>=0.18.1 six>=1.5.0 smart_open>=1.2.1"
elif [[ "$PACKAGE" == "preshed" ]]; then
	PYTHON_DEPS="cymem>=1.30,<1.32.0"
elif [[ "$PACKAGE" == "cytoolz" ]]; then
	PYTHON_DEPS="toolz>=0.8.0"
elif [[ "$PACKAGE" == "thinc" ]]; then
	if [[ "$VERSION" == "6.12.0" ]]; then
		PYTHON_DEPS="cython>=0.25.0 numpy>=1.7.0 msgpack>=0.5.6,<1.0.0 msgpack-numpy==0.4.1 murmurhash>=0.28.0,<0.29.0 cymem>=1.30.0,<1.32.0 preshed>=1.0.0,<2.0.0 cytoolz>=0.9.0,<0.10 wrapt>=1.10.0,<1.11.0 plac>=0.9.6,<1.0.0 tqdm>=4.10.0,<5.0.0 six>=1.10.0,<2.0.0 hypothesis<3,>=2 dill>=0.2.7,<0.3.0 pathlib==1.0.1;python_version<'3.4'"
	else
		PYTHON_DEPS="murmurhash>=0.28.0,<1.1.0 cymem>=2.0.2,<2.1.0 preshed>=2.0.1,<2.1.0 blis>=0.2.1,<0.3.0 srsly>=0.0.4,<1.1.0 wasabi>=0.0.9,<1.1.0 numpy>=1.7.0 plac>=0.9.6,<1.0.0 tqdm>=4.10.0,<5.0.0 pathlib==1.0.1;python_version<'3.4' cython>=0.25.0 hypothesis>=2.0.0,<3.0.0 pytest>=3.6.0,<4.0.0 mock>=2.0.0,<3.0.0 flake8>=3.5.0,<3.6.0"
	fi
elif [[ "$PACKAGE" == "spacy" ]]; then
	if [[ "$VERSION" == "2.0.16" ]]; then
		PYTHON_DEPS="cython>=0.24,<0.28.0 numpy>=1.7 murmurhash>=0.28,<0.29 cymem<1.32,>=1.30 preshed>=1.0.0,<2.0.0 thinc>=6.10.3,<6.11.0 plac<1.0.0,>=0.9.6 ujson>=1.35 dill>=0.2,<0.3 regex==2017.4.5 requests>=2.13.0,<3.0.0 pathlib==1.0.1;python_version<'3.4'"
	else
		PYTHON_DEPS="cymem>=2.0.2,<2.1.0 preshed>=2.0.1,<2.1.0 thinc>=7.0.2,<7.1.0 blis>=0.2.2,<0.3.0 murmurhash>=0.28.0,<1.1.0 wasabi>=0.2.0,<1.1.0 srsly>=0.0.5,<1.1.0 numpy>=1.15.0 requests>=2.13.0,<3.0.0 jsonschema>=2.6.0,<3.1.0 plac<1.0.0,>=0.9.6 pathlib==1.0.1;python_version<'3.4' cython>=0.25 pytest>=4.0.0,<4.1.0 pytest-timeout>=1.3.0,<2.0.0 mock>=2.0.0,<3.0.0 flake8>=3.5.0,<3.6.0"
	fi
elif [[ "$PACKAGE" == "fast5_research" ]]; then
	PYTHON_DEPS="numpy h5py"
elif [[ "$PACKAGE" == "sphinx-argparse" ]]; then
	PYTHON_IMPORT_NAME="sphinxarg"
elif [[ "$PACKAGE" == "jsonnet" ]]; then
	PYTHON_IMPORT_NAME="_jsonnet"
elif [[ "$PACKAGE" == "Unidecode" ]]; then
	PYTHON_IMPORT_NAME=""
elif [[ "$PACKAGE" == "pycryptodome" ]]; then
	PYTHON_IMPORT_NAME="Crypto"
elif [[ "$PACKAGE" == "pyproj" ]]; then
	MODULE_BUILD_DEPS="proj geos"
elif [[ "$PACKAGE" == "pyshp" ]]; then
	PYTHON_IMPORT_NAME="shapefile"
elif [[ "$PACKAGE" == "basemap" ]]; then
	if [[ -z "$VERSION" ]]; then
		VERSION="1.2.0"
	fi
	if [[ "$VERSION" == "1.2.0" ]]; then
		PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/matplotlib/basemap/archive/v1.2.0rel.tar.gz"
		PACKAGE_DOWNLOAD_NAME="v1.2.0rel.tar.gz"
		PRE_BUILD_COMMANDS="sed -i \"s/__version__ = '1.1.0'/__version__ = '1.2.0'/\"  lib/mpl_toolkits/basemap/__init__.py"
	else
		PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/matplotlib/basemap/archive/v${VERSION}.tar.gz"
		PACKAGE_DOWNLOAD_NAME="v${VERSION}.tar.gz"
	fi
	PACKAGE_FOLDER_NAME="basemap-${VERSION}"
	MODULE_BUILD_DEPS="proj geos"
	PYTHON_DEPS="numpy matplotlib pyproj pyshp python-dateutil"
	PRE_DOWNLOAD_COMMANDS="export GEOS_DIR=${EBROOTGEOS} "
	PYTHON_IMPORT_NAME="mpl_toolkits.basemap"
elif [[ "$PACKAGE" == "MDAnalysis" ]]; then
	PYTHON_DEPS="gsd Cython joblib numpy mock GridDataFormats scipy matplotlib networkx biopython mmtf-python six duecredit"
elif [[ "$PACKAGE" == "MDAnalysisTests" ]]; then
	PYTHON_DEPS="MDAnalysis hypothesis pytest joblib pbr"
elif [[ "$PACKAGE" == "attrs" ]]; then
	PYTHON_IMPORT_NAME="attr"
elif [[ "$PACKAGE" == "Cartopy" ]]; then
	if [[ "$RSNT_ARCH" == "avx" ]]; then
		MODULE_BUILD_DEPS="gcc/5.4.0 proj/4.9.3 geos gdal"
	else
		MODULE_BUILD_DEPS="proj/4.9.3 geos gdal"
	fi
	PYTHON_DEPS="Cython numpy shapely pyshp six Pillow pyepsg pykdtree scipy OWSLib"
	PRE_BUILD_COMMANDS="pip freeze"
elif [[ "$PACKAGE" == "pykdtree" ]]; then
	MODULE_BUILD_DEPS="imkl"
elif [[ "$PACKAGE" == "GPy" ]]; then
	PYTHON_DEPS="numpy matplotlib"
elif [[ "$PACKAGE" == "GPyOpt" ]]; then
	PYTHON_DEPS="matplotlib"
elif [[ "$PACKAGE" == "blmath" ]]; then
	PRE_BUILD_COMMANDS='sed -i -e "s@-fno-inline@-fno-inline\x27,\x27-L${EBROOTSUITESPARSE}/lib@g" setup.py; sed -i -e "s@/usr/include/suitesparse@${EBROOTSUITESPARSE}/include@g" setup.py; sed -i -e "s@lapack@mkl@g" setup.py'
	MODULE_BUILD_DEPS="suitesparse imkl"
	PYTHON_DEPS="numpy"
	PYTHON_VERSIONS="python/2.7"
elif [[ "$PACKAGE" == "jcvi" ]]; then
	# aka ALLMAPS
	PYTHON_DEPS="biopython numpy deap networkx matplotlib cython"
elif [[ "$PACKAGE" == "blis" ]]; then
	PYTHON_DEPS="numpy cython pytest hypothesis wheel"
elif [[ "$PACKAGE" == "neuralcoref" ]]; then
	PYTHON_DEPS="cython>=0.25 pytest spacy>=2.1.0"
elif [[ "$PACKAGE" == "torch_scatter" ]]; then
	PYTHON_DEPS="torch>=1.1.0"
	MODULE_BUILD_DEPS="gcc/7.3.0 cuda/10"
elif [[ "$PACKAGE" == "torch_sparse" ]]; then
	PYTHON_DEPS="torch>=1.1.0 torch-scatter"
	MODULE_BUILD_DEPS="gcc/7.3.0 cuda/10"
elif [[ "$PACKAGE" == "torch_cluster" ]]; then
	PYTHON_DEPS="torch>=1.1.0"
	MODULE_BUILD_DEPS="gcc/7.3.0 cuda/10"
elif [[ "$PACKAGE" == "torch_spline_conv" ]]; then
	PYTHON_DEPS="torch>=1.1.0"
	MODULE_BUILD_DEPS="gcc/7.3.0 cuda/10"
elif [[ "$PACKAGE" == "plyfile" ]]; then
	PYTHON_DEPS="numpy"
elif [[ "$PACKAGE" == "torch_geometric" ]]; then
	PYTHON_DEPS="torch>=1.1.0 torch-scatter torch-sparse torch-cluster torch-spline-conv"
	MODULE_BUILD_DEPS="gcc/7.3.0 cuda/10"
elif [[ "$PACKAGE" == "dgl-cpu" ]]; then
	# The v0.2 is CPU only, GPU is in HEAD of the repo or the next release
	PACKAGE="dgl"
	PACKAGE_SUFFIX="-cpu"
	PACKAGE_DOWNLOAD_NAME=$PACKAGE
	PYTHON_IMPORT_NAME=$PACKAGE
	PACKAGE_FOLDER_NAME=$PACKAGE
	MODULE_BUILD_DEPS="cmake"
	PYTHON_DEPS="cython numpy scipy networkx torch"
	PACKAGE_DOWNLOAD_METHOD="Git"
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/dmlc/dgl"
	PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v$VERSION $PACKAGE_FOLDER_NAME"
	POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
	PRE_BUILD_COMMANDS="mkdir build && cd build && cmake .. && make -j 16 && cd ../python "
elif [[ "$PACKAGE" == "dgl-gpu" ]]; then
	# The v0.2 is CPU only, GPU is in HEAD of the repo or the next release
	PACKAGE="dgl"
	PACKAGE_SUFFIX="-gpu"
	PACKAGE_DOWNLOAD_NAME=$PACKAGE
	PYTHON_IMPORT_NAME=$PACKAGE
	PACKAGE_FOLDER_NAME=$PACKAGE
	MODULE_BUILD_DEPS="cmake cuda/10"
	PYTHON_DEPS="cython numpy scipy networkx torch"
	PACKAGE_DOWNLOAD_METHOD="Git"
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/dmlc/dgl"
	PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v$VERSION $PACKAGE_FOLDER_NAME"
	POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
	PRE_BUILD_COMMANDS="mkdir build && cd build && cmake -DUSE_OPENMP=ON -DUSE_CUDA=ON .. && make -j 16 && cd ../python "
elif [[ "$PACKAGE" == "feather-format" ]]; then
	MODULE_RUNTIME_DEPS="gcc/7.3.0 boost/1.68.0 arrow/0.11.1"
	PYTHON_IMPORT_NAME="feather"
elif [[ "$PACKAGE" == "pyabc" ]]; then
	MODULE_RUNTIME_DEPS="gcc/7.3.0 boost/1.68.0 arrow/0.11.1 scipy-stack"
elif [[ "$PACKAGE" == "simuPOP" ]]; then
	MODULE_RUNTIME_DEPS="gcc/7.3.0 boost/1.68.0 gsl/2.5 scipy-stack"
elif [[ "$PACKAGE" == "ipython" ]]; then
	PYTHON_IMPORT_NAME=""
elif [[ "$PACKAGE" == "spotpy" ]]; then
	PYTHON_DEPS="numpy"
elif [[ "$PACKAGE" == "guildai" ]]; then
	MODULE_BUILD_DEPS="nodejs scipy-stack"
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/guildai/guildai/archive/$VERSION.tar.gz"
	PACKAGE_DOWNLOAD_NAME="$VERSION.tar.gz"
	PYTHON_IMPORT_NAME="guild"
elif [[ "$PACKAGE" == "nvidia_dali" ]]; then
	MODULE_BUILD_DEPS="cmake/3.12.3 cuda/10 opencv/4.1.0 protobuf/3.7.1 boost/1.68.0"
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/NVIDIA/DALI"
	PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
	PACKAGE_DOWNLOAD_METHOD="Git"
	PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v$VERSION $PACKAGE_FOLDER_NAME"
	POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
	PRE_BUILD_COMMANDS="mkdir build && cd build && cmake -DCMAKE_SKIP_RPATH=ON -DBUILD_NVJPEG=OFF -DCMAKE_PREFIX_PATH=$EBROOTPROTOBUF -DProtobuf_INCLUDE_DIRS=$EBROOTPROTOBUF/include -DProtobuf_LIBRARIES=$EBROOTPROTOBUF/lib64 -DProtobuf_LIBRARY=$EBROOTPROTOBUF/lib64/libprotobuf.so ..
 && make -j 16 && cd dali/python "
	RPATH_TO_ADD="\$ORIGIN:\ORIGIN/.."  # Force origin. Equivalent to use `--add_origin`.
elif [[ "$PACKAGE" == "unicycler" ]]; then
	# Unicycler is not published on PyPI
	# https://github.com/rrwick/Unicycler
	PYTHON_VERSIONS="python/3.5 python/3.6 python/3.7"
	if [[ -z "$VERSION" ]]; then
		VERSION="0.4.8"
	fi
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/rrwick/Unicycler/archive/v${VERSION}.tar.gz"
	PACKAGE_DOWNLOAD_NAME="v${VERSION}.tar.gz"
	PACKAGE_FOLDER_NAME="Unicycler-${VERSION}"
fi

function single_test_import {
	CONST_NAME="$1"
	NAME="$2"
	TESTS="$3"
	if [[ "$NAME" != "$CONST_NAME" ]]; then
		echo "Testing import with name $NAME"
		$PYTHON_CMD -c "import $NAME; $TESTS"
		RET=$?
		test $RET -eq 0  && echo "Sucess!" || echo "Failed"
		return $RET
	else
		return 1
	fi
}
function test_import {
	NAME=$1
	TESTS=$2

	# dashes in names are always replaced by underscore
	NAME=${NAME//-/_}
	
	CONST_NAME="$NAME"
	echo "Testing import with name $NAME"
	$PYTHON_CMD -c "import $NAME; $TESTS"
	RET=$?
	test $RET -eq 0  && echo "Sucess!" || echo "Failed"

	if [[ $RET -ne 0 ]]; then
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//python_/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//_python/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//py_/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//Py_/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//_py/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//_Py/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//Py/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//py/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME%2}"       #surprisingly, many packages have a name that ends with 2, but import without the 2
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME}2"       #the other way also happens... 
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//scikit_/sk}"   #special case for all of the scikit- packages
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//_/.}"   #replacing _ by . sometimes happens
		# add a version of all in lower cases
		NAMES_TO_TEST="$NAMES_TO_TEST ${NAMES_TO_TEST,,}"
		# remove duplicates
		for TEST_NAME in $NAMES_TO_TEST; do 
			if [[ ! $NAMES_TO_TEST2 =~ $TEST_NAME ]]; then
				NAMES_TO_TEST2="$NAMES_TO_TEST2 $TEST_NAME"
			fi
		done
		NAMES_TO_TEST=$NAMES_TO_TEST2
		echo "Testing imports with the following names $NAMES_TO_TEST"
		if [[ $RET -ne 0 ]]; then
			RET=1
			for TEST_NAME in $NAMES_TO_TEST; do 
				single_test_import "$CONST_NAME" "$TEST_NAME" "$TESTS"
				RET=$?
				if [[ $RET -eq 0 ]]; then break; fi
			done
		fi
	fi
	return $RET

}

DIR=tmp.$$
mkdir $DIR
pushd $DIR
module --force purge
module load nixpkgs gcc/7.3.0
for pv in $PYTHON_VERSIONS; do
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		module load $MODULE_BUILD_DEPS
	fi
	if [[ -n "$MODULE_RUNTIME_DEPS" ]]; then
		module load $MODULE_RUNTIME_DEPS
	fi
	module load $pv
	module list

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
		pip install $PYTHON_DEPS --find-links=$TMP_WHEELHOUSE
	fi
	pip freeze
	eval $PRE_DOWNLOAD_COMMANDS
	echo "Downloading source"
	mkdir $PVDIR
	eval $PACKAGE_DOWNLOAD_CMD
	eval $POST_DOWNLOAD_COMMANDS
	if [[ $PACKAGE_DOWNLOAD_NAME =~ (.zip|.tar.gz|.tgz|.whl|.tar.bz2)$ ]]; then
		ARCHNAME="$PACKAGE_DOWNLOAD_NAME"
	else
		ARCHNAME=$(ls $PACKAGE_DOWNLOAD_NAME-[0-9]*{.zip,.tar.gz,.tgz,.whl,.tar.bz2})
	fi
	# skip packages that are already in whl format
	if [[ $ARCHNAME == *.whl ]]; then
		# Patch the content of the wheel file.
		eval "$PATCH_WHEEL_COMMANDS"
		cp -v $ARCHNAME ..
		continue
	fi
	unzip $ARCHNAME -d $PVDIR || tar xfv $ARCHNAME -C $PVDIR
	pushd $PVDIR
	pushd $PACKAGE_FOLDER_NAME*

	echo "Patching"
	for p in $PATCHES;
	do
		patch --verbose -p1 < $p
	done

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
	eval $PRE_BUILD_COMMANDS_DEFAULT
	# change the name of the wheel to add a suffix
	if [[ -n "$PACKAGE_SUFFIX" ]]; then
		sed -i -e "s/name='$PACKAGE'/name='$PACKAGE$PACKAGE_SUFFIX'/g" $(find . -name "setup.py")
	fi
	$PYTHON_CMD setup.py bdist_wheel $BDIST_WHEEL_ARGS |& tee build.log
	pushd dist || cat build.log
	WHEEL_NAME=$(ls *.whl)
	eval "$POST_BUILD_COMMANDS"
	if [[ -n "$RPATH_TO_ADD" ]]; then
		echo "Running /cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path=$RPATH_TO_ADD --any_interpreter"
		/cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path $RPATH_TO_ADD --any_interpreter
	fi
	pwd
	ls
	cp -v $WHEEL_NAME $TMP_WHEELHOUSE
	popd
	popd
	popd

	echo "Testing..."
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		module unload $MODULE_BUILD_DEPS
	fi
	module list
	pip install ../$WHEEL_NAME --no-cache --find-links=$TMP_WHEELHOUSE
	if [[ -n "$PYTHON_IMPORT_NAME" ]]; then
		test_import "$PYTHON_IMPORT_NAME" "$PYTHON_TESTS"
	fi
	SUCCESS=$?
	deactivate
	if [[ $SUCCESS -ne 0 ]]; then
		echo "Error happened"
		cd ..
		exit $SUCCESS
	fi

	if [[ $WHEEL_NAME =~ .*-py3-.* || $WHEEL_NAME =~ .*py2.py3.* ]]; then
		echo "Wheel is compatible with all further versions of python. Breaking"
		break
	fi
done

popd

echo "Build done, you can now remove $DIR"
echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/[generic,avx2,avx,sse3] and synchronize CVMFS"
