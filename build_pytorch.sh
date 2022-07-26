#!/bin/bash

set -e

function usage()
{
  echo "usage: build_pytorch.sh [--version <version>] --commit <sha1> [--python {2.7,3.5,3.6,3.7...}] [--jobs <N>] [--arch avx2|avx512]" >&2
}

version=""
commit=""
python_versions=$(ls -1 /cvmfs/soft.computecanada.ca/easybuild/software/20*/Core/python/3* /cvmfs/soft.computecanada.ca/easybuild/software/2020/avx*/Core/python/3* | grep -Po "3.[7-9]" | sort -u)
jobs=$(grep -c "^processor" /proc/cpuinfo)
archs="avx2 avx512"

while [[ $# -gt 0 ]] && [[ ."$1" == .--* ]] ;
do
    opt="$1";
    shift;              #expose next argument
    case "$opt" in
        "--" ) break 2;;
        "--version") version="$1"; shift;;
        "--commit") commit="$1"; shift;;
        "--python") python_versions="$1"; shift;;
        "--jobs")   jobs="$1"; shift;;
        "--arch")   archs="$1"; shift;;
        *) echo "Invalid option: $opt" >&2; usage; exit 1;;
    esac
done

echo "Start building at $(date)..."
echo "pytorch version ($version) commit ($commit)"
echo "pythons: $python_versions"
echo "archs: $archs"
echo ""

function mk_cd()
{
    local dir=${1?Missing directory name}

    mkdir -p $dir
    cd $dir
    pwd
}

mk_cd "/tmp/$USER/pytorch_build_$(date +"%Y-%m-%d_%H-%M-%S")"
build_dir=$(pwd)

for arch in $archs; do
    mk_cd $arch
    for pv in $python_versions; do
        mk_cd "python${pv}"

        module purge
        module unload imkl
        module load arch/$arch python/$pv gcc/9.3.0 flexiblas cuda/11.4 magma nccl cudnn ffmpeg cmake flexiblas fftw eigen one-dnn opencv protobuf
        module list

        git clone --recursive --jobs 16 https://github.com/pytorch/pytorch.git -b v$version && cd pytorch
        virtualenv env${pv} && source env${pv}/bin/activate

        # if [[ ! -z "$version" ]]; then
        #     git checkout tags/"v${version}"
        # elif [[ ! -z "$commit" ]]; then
        #     git checkout ${commit}
        # fi
        # git show --oneline -s

        # Install deps
        pip install ninja 'numpy>=1.21.2'
        pip install -r requirements.txt

        export PYTORCH_BUILD_VERSION=$version # Set the version to overwrite the one hardcoded in setup.py
        export PYTORCH_BUILD_NUMBER=0

        export CMAKE_LIBRARY_PATH="$EBROOTFLEXIBLAS/lib:$EBROOTONEMINDNN/lib64:$CMAKE_LIBRARY_PATH"
        export CMAKE_INCLUDE_PATH="$EBROOTFLEXIBLAS/include/flexiblas:$EBROOTONEMINDNN/include:$CMAKE_INCLUDE_PATH"
        export CMAKE_PREFIX_PATH=$VIRTUALENV/lib/python${EBVERSIONPYTHON::3}/site-packages:$EBROOTFLEXIBLAS/include/flexiblas:$EBROOTFLEXIBLAS/lib:$EBROOTCUDNN/lib64:$EBROOTNCCL/lib:$EBROOTFFTW/lib:$EBROOTEIGEN/include:$EBROOTEIGEN/lib:$EBROOTGENTO/lib64:$EBROOTGENTO/include:$CMAKE_PREFIX_PATH;

        export MAX_JOBS=$jobs;
        export DEBUG=OFF;
        export BUILD_TEST=OFF;
        export INSTALL_TEST=OFF;
        export TORCH_CUDA_ARCH_LIST="6.0;7.0;7.5;8.0;8.6";
        export NO_CUDA=OFF;
        export MAGMA_HOME=$EBROOTMAGMA;

        export USE_CUDNN=ON;
        export CUDNN_LIB_DIR=$EBROOTCUDNN/lib64;
        export CUDNN_INCLUDE_DIR=$EBROOTCUDNN/include;
        export CUDNN_LIBRARY=$EBROOTCUDNN/lib64/libcudnn.so
        export CUDNN_LIBRARY_PATH=$EBROOTCUDNN/lib64/libcudnn.so

        export USE_SYSTEM_NCCL=ON;
        export NCCL_ROOT=$EBROOTNCCL;
        export NCCL_LIB_DIR=$EBROOTNCCL/lib;
        export NCCL_INCLUDE_DIR=$EBROOTNCCL/include;

        export BUILD_CUSTOM_PROTOBUF=OFF
        export USE_SYSTEM_EIGEN_INSTALL=ON

        export USE_OPENCV=ON;
        export USE_FFMPEG=ON;
        export USE_ZSTD=ON;

        export BLAS=FlexiBLAS;
        export USE_BLAS=ON;
        export USE_LAPACK=ON;
        export USE_IBVERBS=ON;
        # export BUILD_CAFFE2=ON;

        # export TH_BINARY_BUILD=ON;
        # export USE_DISTRIBUTED=ON;
        # export USE_GLOO=ON;
        # export USE_GLOO_WITH_OPENSSL=ON;

        python setup.py bdist_wheel |& tee build.log

        # # setrpaths.sh --path dist/torch*.whl --any_interpreter

        # mv -v build.log dist/torch*.whl requirements.txt test/ ../
        wheel=$(echo "$(pwd)/$(ls dist/torch*.whl)")

        cd .. # Get out of `pytorch` directory
        # rm -rf pytorch

        # Run small test outside of build directory (namespace clash)
        module purge && module load python/$pv && module list

        virtualenv test
        source test/bin/activate

        pip install --no-index numpy protobuf $wheel
        pip install -r pytorch/requirements.txt

        # smoke tests
        echo "Checking that Pytorch is available and working"
        python -c "import torch; x=torch.inverse(torch.rand(4,4)); print(x if not torch.cuda.is_available() else x.cuda());"
        python -c "import torch; x=torch.svd(torch.rand(4,4)); print(x if not torch.cuda.is_available() else x.cuda());"

        # echo "Checking that CAFF2 is availablei and working"
        # python -c "from caffe2.python import workspace, model_helper; import numpy as np; workspace.FeedBlob('my_x', np.random.rand(4, 3, 2)); print(workspace.FetchBlob('my_x'));"

        # echo "Checking that MKL is available"
        # python -c 'import torch; print(torch.backends.mkl.is_available())'

        # Run extensive testing, GPUs tests needs to be manually ran on a GPU node.
        # Avoid huge performance hit with multithreads in tests
        #OMP_NUM_THREADS=2 python test/run_test.py --verbose |& tee tests.log

        cd .. # Get out of $python directory
    done # pythons
done

echo "Done building at $(date)"
