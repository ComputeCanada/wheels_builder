#!/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/bin/bash

module load \
    bazel \
    python/2.7 \
    scipy-stack

set -x
shopt -s nullglob

WDIR=$(pwd)
BDIR=$(mktemp -d)

cd $BDIR
git clone --depth=1 --branch=release-2018-06-20 https://github.com/deepmind/lab
cd *
git apply $WDIR/cc_build.patch

bazel clean --expunge
bazel build\
	-c opt \
	--jobs 24 \
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
