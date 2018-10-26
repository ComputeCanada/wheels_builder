#!/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/bin/bash

shopt -s nullglob
set -e
PYVER="$1"

if [[ ! -f "cc_build_py$PYVER.patch" ]] ; then
    "Unable to find patch file for python version $PYVER. Dying"
    exit 1
fi

module load \
    bazel \
    python/$PYVER \
    scipy-stack

set -x

WDIR=$(pwd)
BDIR=$(mktemp -d)

cd $BDIR
git clone --depth=1 --branch=release-2018-06-20 https://github.com/deepmind/lab
cd *
git apply $WDIR/cc_build_py$PYVER.patch

bazel clean --expunge
bazel build\
	-c opt \
	--jobs 24 \
    --verbose_failures \
	--action_env=C_INCLUDE_PATH="${C_INCLUDE_PATH}:$(python -c 'import numpy; print(numpy.get_include())')"\
	--action_env=LIBFFI_CFLAGS="-I/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/include"\
	--action_env=LIBFFI_LIBS="-L/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/lib -lffi"\
	--action_env=LIBEGL="-L/usr/lib64/nvidia/ -lEGL"\
	--define headless=osmesa\
	python/pip_package:build_pip_package

ODIR=$(mktemp -d)
./bazel-bin/python/pip_package/build_pip_package $ODIR

if [[ ! -z $ODIR/*.whl ]] ; then
    echo "Wheel created at " $ODIR/*.whl
else
    echo "Wheel not created successfully"
fi

cd $WDIR
rm -rf $BDIR
