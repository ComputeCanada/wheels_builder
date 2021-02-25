#!/bin/bash

function ls_pythons()
{
	ls -1d /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/3* | grep -v 3.5 | grep -Po "\d\.\d" | sort -u | tr '\n' ','
}

function print_usage
{
	echo "Usage: $0 --package <package name> [--version <version>] [--python <comma separated list of python versions>]"
}

TEMP=$(getopt -o h --longoptions help,package:,version:,python:,add_path:,add_origin --name $0 -- "$@")
if [ $? != 0 ] ; then print_usage; exit 1 ; fi
eval set -- "$TEMP"

ARG_PACKAGE=""
ARG_VERSION=""
ARG_ADD_PATH=""
ARG_ADD_ORIGIN=0
while true; do
	case "$1" in
		--package)
			ARG_PACKAGE=$2; shift 2;;
		--version)
			ARG_VERSION=$2; shift 2;;
		--python)
			ARG_PYTHON_VERSIONS=$2; shift 2;;
		--add_path)
			ARG_ADD_PATH=$2; shift 2 ;;
		--add_origin)
			ARG_ADD_ORIGIN=1; shift 1;;
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

if [[ -n "$ARG_VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$ARG_PACKAGE==$ARG_VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$ARG_PACKAGE"
fi

CONFIGDIR=$(dirname $0)/config
if [[ -e "$CONFIGDIR/${ARG_PACKAGE}-${ARG_VERSION}.sh" ]]; then
	source $CONFIGDIR/${ARG_PACKAGE}-${ARG_VERSION}.sh
elif [[ -e "$CONFIGDIR/${ARG_PACKAGE}.sh" ]]; then
	source $CONFIGDIR/${ARG_PACKAGE}.sh
fi

TEMP_DIR=tmp.$$
mkdir $TEMP_DIR
cd $TEMP_DIR
for pv in $(echo ${ARG_PYTHON_VERSIONS-$(ls_pythons)} | tr ',' ' '); do
	module load python/$pv
	python -m venv env-$pv && source env-$pv/bin/activate
	pip install -U pip
	PYTHONPATH= pip download --no-deps $PACKAGE_DOWNLOAD_ARGUMENT
	deactivate
done

setrpaths_cmd="setrpaths.sh --path \$ARCHNAME"
if [[ ! -z "$ARG_ADD_PATH" ]]; then
	setrpaths_cmd="${setrpaths_cmd} --add_path ${ARG_ADD_PATH} --any_interpreter"
fi
if [[ "$ARG_ADD_ORIGIN" == "1" ]]; then
	setrpaths_cmd="${setrpaths_cmd} --add_origin"
fi
for ARCHNAME in *.whl; do
	eval $setrpaths_cmd
	eval "$PATCH_WHEEL_COMMANDS"
	mv $ARCHNAME ${ARCHNAME//$(echo $ARCHNAME | grep -Po "manylinux\d+")/linux}
done

# Ensure wheels are all readable!
chmod a+r *.whl
cp -vp *.whl ..
cd ..
rm -rf $TEMP_DIR
