#!/bin/bash

if [[ -z "$PYTHON_VERSIONS" ]]; then
        PYTHON_VERSIONS=$(ls -1d /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/3* | grep -v 3.5 | grep -Po "\d\.\d" | sort -u | sed 's#^#python/#')
fi

PACKAGE=${1?Missing package name}
VERSION=$2
if [[ -n "$VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE==$VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
fi

TEMP_DIR=tmp.$$
mkdir $TEMP_DIR
cd $TEMP_DIR
for pv in $PYTHON_VERSIONS; do
	module load $pv
	PYTHONPATH= pip download --no-deps $PACKAGE_DOWNLOAD_ARGUMENT
done
for w in *.whl; do
	setrpaths.sh --path $w
	mv $w ${w//$(echo $w | grep -Po "manylinux\d+")/linux}
done
# Ensure wheels are all readable!
chmod a+r *.whl
cp -vp *.whl ..
cd ..
rm -rf $TEMP_DIR
