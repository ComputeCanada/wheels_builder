#!/bin/bash

if [[ -z "$PYTHON_VERSIONS" ]]; then
    PYTHON_VERSIONS=$(ls -1 /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/ | grep -Po "\d\.\d" | sort -u | sed 's#^#python/#')
fi

PACKAGE=${1?Missing package name}
VERSION=$2
if [[ -n "$VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE==$VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
fi

TMPDIR=tmp.$$
mkdir $TMPDIR
cd $TMPDIR
for pv in $PYTHON_VERSIONS; do
	module load $pv
	PYTHONPATH= pip download --no-deps $PACKAGE_DOWNLOAD_ARGUMENT
done
for w in *.whl; do
	setrpaths.sh --path $w
	mv $w ${w//$(echo $w | grep -Po "manylinux\d+")/linux}
done
mv *.whl ..
cd ..
rm -rf $TMPDIR
