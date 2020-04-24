#!/bin/bash

function ls_pythons()
{
	ls -1d /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/3* | grep -v 3.5 | grep -Po "\d\.\d" | sort -u | tr '\n' ','
}

function print_usage
{
	echo "Usage: $0 --package <package name> [--version <version>] [--python <comma separated list of python versions>]"
}

TEMP=$(getopt -o h --longoptions help,package:,version:,python: --name $0 -- "$@")
if [ $? != 0 ] ; then print_usage; exit 1 ; fi
eval set -- "$TEMP"

ARG_PACKAGE=""
ARG_VERSION=""
while true; do
	case "$1" in
		--package)
			ARG_PACKAGE=$2; shift 2;;
		--version)
			ARG_VERSION=$2; shift 2;;
		--python)
			ARG_PYTHON_VERSIONS=$2; shift 2;;
		-h|--help)
			print_usage; exit 0 ;;
		--)
			shift; break ;;
		*) echo "Unknown parameter $1"; print_usage; exit 1 ;;
	esac
done

if [[ -z "$ARG_PACKAGE" ]]; then
	print_usage
	exit 1
fi

if [[ -n "$VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$ARG_PACKAGE==$ARG_VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$ARG_PACKAGE"
fi

TEMP_DIR=tmp.$$
mkdir $TEMP_DIR
cd $TEMP_DIR
for pv in $(echo ${ARG_PYTHON_VERSIONS-$(ls_pythons)} | tr ',' ' '); do
	module load python/$pv
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
