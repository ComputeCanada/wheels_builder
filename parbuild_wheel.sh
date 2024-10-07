#!/bin/bash

# Build multiple versions of a wheel in parallel.
# To terminate, ctrl+c or `killall -TERM parallel`


YEAR="${EBVERSIONGENTOO:-2017}"
EXCLUDE_PYTHON_VERSIONS="/2\.\|/3.[5678]"
if [[ "$YEAR" == "2023" ]]; then
	EXCLUDE_PYTHON_VERSIONS="/2\.\|/3.[56789]"
fi

function ls_pythons()
{
	module --terse spider python | grep -v "$EXCLUDE_PYTHON_VERSIONS" | grep -Po "\d\.\d+" | sort -Vu | tr '\n' ' '
}

function print_usage
{
	echo "Usage: $0 --package <comma separated list of package name> [--version <comma separated list of versions>] [--python <comma separated list of python versions>]"
}

TEMP=$(getopt -o h --longoptions help,package:,version:,python:,requirements: --name $0 -- "$@")
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
		--requirements)
			ARG_REQUIREMENTS=$2; shift 2;;
		-h|--help)
			print_usage; exit 0 ;;
		--)
			shift; break ;;
		*) echo "Unknown parameter $1"; print_usage; exit 1 ;;
	esac
done

if [[ (-z "$ARG_PACKAGE" && -z "$ARG_REQUIREMENTS") ]]; then
	print_usage
	exit 1
fi

pythons=$(echo ${ARG_PYTHON_VERSIONS-$(ls_pythons)})

logfile="$$.log"
cmdsfile="$$.cmds"

if [[ ! -z "$ARG_REQUIREMENTS" ]]; then
	cmd1="bash build_wheel.sh --package {1} --version {2} --python {3} --recursive 0 --verbose 3 &> build-{1}-{2}-py{3}.log :::: - ::: ${pythons}"
	cmd2="bash build_wheel.sh --package {1} --python {2} --recursive 0 --verbose 3 &> build-{1}-py{2}.log :::: - ::: ${pythons}"

	# Keep only requirements == lines
	awk '/^\w+==(\w|\.)+$/ {print $1}' $ARG_REQUIREMENTS | sed 's/;$//' | parallel --colsep '==' --dry-run $cmd1 | tee -a $cmdsfile
	# Keep only named requirements lines
	awk '/^\w+$/ {print $1}' $ARG_REQUIREMENTS | sed 's/;$//' | parallel --dry-run $cmd2 | tee -a $cmdsfile
	parallel --joblog $logfile < $cmdsfile
else
	wheel=${ARG_PACKAGE//,/ }
	versions=${ARG_VERSION//,/ }
	pythons=${pythons//,/ }

	if [[ -n "$versions" ]]; then
		cmd="bash build_wheel.sh --package {1} --version {2} --python {3} --recursive 0 --verbose 3 &> build-{1}-{2}-py{3}.log ::: ${wheel} ::: ${versions} ::: ${pythons}"
	else
		cmd="bash build_wheel.sh --package {1} --python {2} --recursive 0 --verbose 3 &> build-{1}-py{2}.log ::: ${wheel} ::: ${pythons}"
	fi

	# Yes, two times the command, display what will be run and then run it.
	parallel --dry-run          $cmd
	parallel --joblog $logfile  $cmd
	echo $logfile && cat $logfile
fi
