#!/bin/bash

THIS_SCRIPT=$0
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$THIS_SCRIPT")")
EXCLUDE_PYTHON_VERSIONS="/2\.\|/3.[5678]"
if [[ "${EBVERSIONGENTOO:-2017}" == "2023" ]]; then
	EXCLUDE_PYTHON_VERSIONS="/2\.\|/3.[56789]\|3.10"
fi

function ls_pythons()
{
	module --terse spider python | grep -v "$EXCLUDE_PYTHON_VERSIONS" | grep -Po "\d\.\d+" | sort -Vu | tr '\n' ','
}

function print_usage
{
	echo "Usage: $0 --package <package name> [--version <version>] [--python <comma separated list of python versions>] [--add_path <rpath>] [--add_origin] [--find_links https://index.url | --url https://direct.url.to.wheel.whl ]"
}

TEMP=$(getopt -o h --longoptions help,package:,version:,python:,add_path:,find_links:,url:,add_origin --name $0 -- "$@")
if [ $? != 0 ] ; then print_usage; exit 1 ; fi
eval set -- "$TEMP"
START_DIR=$(pwd)
ARG_PACKAGE=""
ARG_VERSION=""
ARG_ADD_PATH=""
ARG_ADD_ORIGIN=0
ARG_FIND_LINKS=""
ARG_URL=""
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
		--find_links)
			ARG_FIND_LINKS=$2; shift 2;;
		--url)
			ARG_URL=$2; shift 2;;
		-h|--help)
			print_usage; exit 0 ;;
		--)
			shift; break ;;
		*) echo "Unknown parameter $1"; print_usage; exit 1 ;;
	esac
done

if [[ -z "$ARG_PACKAGE" && -z "$ARG_URL" ]]; then
	print_usage
	exit 1
fi

if [[ -n "$ARG_VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$ARG_PACKAGE==$ARG_VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$ARG_PACKAGE"
fi

CONFIGDIR=$SCRIPT_DIR/config
PACKAGE_PATTERN=$(echo $ARG_PACKAGE | sed -e 's/[_-]/\?/g') # Ignores packages with - or _ replace with ? char for pattern.
# Check case-insensitively if package-version.sh exists.
if [[ -n $(find $CONFIGDIR -iname "${PACKAGE_PATTERN}-${VERSION}.sh") ]]; then
	config_name=$(find $CONFIGDIR -iname "${PACKAGE_PATTERN}-${VERSION}.sh")
	echo "INFO: Sourced configuration $config_name"
	source $config_name

# Check case-insensitively if package.sh exists.
elif [[ -n $(find $CONFIGDIR -iname "${PACKAGE_PATTERN}.sh") ]]; then
	config_name=$(find $CONFIGDIR -iname "${PACKAGE_PATTERN}.sh")
	echo "INFO: Sourced configuration $config_name"
	source $config_name

else
	echo "INFO: no configuration file sourced."
fi

if [[ ! -z "$ARG_FIND_LINKS" ]]; then
	export PIP_FIND_LINKS=$ARG_FIND_LINKS
fi
#a
TEMP_DIR=/tmp/unmanylinuxize_tmp.$$
ORIGINAL_DIR=$(pwd)
mkdir -p $TEMP_DIR
pushd $TEMP_DIR

if [[ ! -z "$ARG_URL" ]]; then
	wget $ARG_URL
else
	for pv in $(echo ${ARG_PYTHON_VERSIONS-$(ls_pythons)} | tr ',' ' '); do
		module load python/$pv
		if [[ "${EBVERSIONGENTOO:-2017}" != "2023" ]]; then
			module load pip/.23.0.1
		fi
		WHEEL_NAME=$(PYTHONPATH= pip download --no-deps $PACKAGE_DOWNLOAD_ARGUMENT  |& tee download.log | grep "Saved " | awk '{print $2}')
		if [[ $WHEEL_NAME =~ .*-py3-.* || $WHEEL_NAME =~ .*py2.py3.* ]]; then
			echo "Wheel $WHEEL_NAME is compatible with all further versions of python. Breaking"
			break
		fi
	done
fi

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
	mv $ARCHNAME ${ARCHNAME//$(echo $ARCHNAME | grep -Po 'manylinux.*x86_64')/linux_x86_64}
done
for ARCHNAME in *.whl; do
	$SCRIPT_DIR/manipulate_wheels.py --insert_local_version --wheels $ARCHNAME --inplace && rm $ARCHNAME
done

# Ensure wheels are all readable!
chmod a+r *.whl
cp -vp *.whl $ORIGINAL_DIR
popd
rm -rf $TEMP_DIR
