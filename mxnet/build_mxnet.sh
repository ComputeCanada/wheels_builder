#!/bin/bash

set -x

TMPDIR=$(mktemp -d)
CURDIR=$(pwd)

do_build() {

    # the module spam is stupid otherwise
    set +x
    while read mod; do
        echo "loading module $mod"
        module load $mod
    done < modules.txt
    set -x

    cd $TMPDIR
    git clone --recursive https://github.com/apache/incubator-mxnet mxnet
    cd mxnet

    # XXX check this patch against a release tag
    git checkout 3e2f752d4
    git apply "$CURDIR/mxnet_ccbuild.patch"

    make clean
    make -j 10

    cd python
    python setup.py bdist_wheel

    cp dist/*.whl "$CURDIR/"
}

set -e
do_build
set +e

cd "$CURDIR"

if [[ $TMPDIR == "/tmp*" ]] ; then
    rm -rf "$TMPDIR"
fi
