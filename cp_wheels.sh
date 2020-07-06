#!/bin/bash

WHEELHOUSE_ROOT="/cvmfs/soft.computecanada.ca/custom/python/wheelhouse"

function print_usage
{
	echo "Usage: $0 [--wheel <wheel file>] [--remove] [--dry-run]"
}

TEMP=$(getopt -o h --longoptions help,remove,dry-run,wheel: --name $0 -- "$@")
if [ $? != 0 ] ; then print_usage; exit 1 ; fi
eval set -- "$TEMP"

ARG_WHEEL=""
ARG_REMOVE=""
ARG_DRY_RUN=""
while true; do
	case "$1" in
		--wheel)
			ARG_WHEEL=$2; shift 2;;
		--remove)
			ARG_REMOVE=1; shift 1;;
		--dry-run)
			ARG_DRY_RUN=1; shift 1;;
		-h|--help)
			print_usage; exit 0 ;;
		--)
			shift; break ;;
		*) echo "Unknown parameter $1"; print_usage; exit 1 ;;
	esac
done


function cp_wheel {
	NAME=$1
	COMPAT=$2
	ARCHITECTURE=$3
	REMOVE=$4

	echo chmod ug+rw,o+r $1
	if [[ "$ARG_DRY_RUN" == "" ]]; then
		chmod ug+rw,o+r $1
	fi
	if [[ "$COMPAT" == "generic" ]]; then
		echo cp $1 $WHEELHOUSE_ROOT/generic
		if [[ "$ARG_DRY_RUN" == "" ]]; then
			cp $1 $WHEELHOUSE_ROOT/generic
		fi
	else 
		echo cp $1 $WHEELHOUSE_ROOT/$COMPAT/$ARCHITECTURE
		if [[ "$ARG_DRY_RUN" == "" ]]; then
			cp $1 $WHEELHOUSE_ROOT/$COMPAT/$ARCHITECTURE
		fi
	fi
	if [[ "$REMOVE" == "1" ]]; then
		echo rm "$1"
		if [[ "$ARG_DRY_RUN" == "" ]]; then
			rm "$1"
		fi
	fi
}

if [[ "$ARG_DRY_RUN" == "1" ]]; then
	echo "Not doing operations (dry-run)"
fi
for w in *.whl; do 
	cp_wheel $w $(bash wheel_architecture.sh $w 2>/dev/null) $ARG_REMOVE 
done

