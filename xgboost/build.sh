set -x
set -e

module load intel/2018.3 cuda/10.0.130
module load nccl/2.3.5

CDIR=$(pwd)
WDIR=$(mktemp -d)
cd $WDIR

# GET SOURCE
git clone --recursive https://github.com/dmlc/xgboost
cd xgboost
NEWTAG=$(git describe --tags)
git checkout $NEWTAG

export CC=$(which icc)
export CXX=$(which icc)

# BASE BUILD

mkdir build
cd build
cmake .. -DUSE_CUDA=ON -DUSE_NCCL=ON -DNCCL_ROOT=$EBROOTNCCL
make -j32

# PYTHON MODULE BUILD
cd ../python-package/
# python 2 generated anyway
for ver in 2.7, 3.6 ; do
    module load python/$ver
    python setup.py bdist_wheel
done

cp ./dist/*.whl $CDIR/

cd $CDIR
rm -rf "$WDIR"
