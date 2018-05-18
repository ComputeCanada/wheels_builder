#!/bin/bash
set -e

TF_VERSION="$1"
PYTHON_VERSIONS="python/2.7 python/3.5 python/3.6"
OPTIONS="-- --gpu"
ARCHS="avx2 avx"
for arch in $ARCHS; do
    mkdir -p $arch
    cd $arch
    for pyv in $PYTHON_VERSIONS; do
        module load $pyv
	for opt in $OPTIONS; do
            ../build_tensorflow.sh -a $arch -v $TF_VERSION $opt
        done
    done
    cd ..
done
