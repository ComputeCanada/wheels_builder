#!/bin/bash

# Build multiple versions of a wheel in parallel.
# To terminate, ctrl+c or `killall -TERM parallel`

function ls_pythons()
{
	ls -1d /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/3* | grep -v 3.5 | grep -Po "\d\.\d" | sort -u | tr '\n' ','
}

function print_usage
{
	echo "Usage: $0 --package <comma separated list of package name> [--version <comma separated list of versions>] [--python <comma separated list of python versions>]"
}

TEMP=$(getopt -o h --longoptions help,package:,version:,python: --name $0 -- "$@")
if [ $? != 0 ] ; then print_usage; exit 1 ; fi
eval set -- "$TEMP"

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

wheel=${ARG_PACKAGE//,/ }
versions=${ARG_VERSION//,/ }
pythons=$(echo ${ARG_PYTHON_VERSIONS-$(ls_pythons)} | tr ',' ' ')

if [[ -n "$versions" ]]; then
	cmd="bash build_wheel.sh --package {1} --version {2} --python {3} &> build-{1}-{2}-py{3}.log ::: ${wheel} ::: ${versions} ::: ${pythons}"
else
	cmd="bash build_wheel.sh --package {1} --python {2} &> build-{1}-py{2}.log ::: ${wheel} ::: ${pythons}"
fi
# Yes, two times the command, display what will be run and then run it.
parallel --dry-run          $cmd
parallel --joblog build.log $cmd
