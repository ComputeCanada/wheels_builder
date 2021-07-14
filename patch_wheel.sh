#!/bin/env bash

THIS_SCRIPT=$0

function print_usage
{
	echo "Usage: $0 --wheel <wheel file> [--cctag]"
	echo "  --cctag will add a '+computecanada' local version ot the wheel"
}

TEMP=$(getopt -o h --longoptions help,wheel:,cctag --name $0 -- "$@")
if [ $? != 0 ] ; then print_usage; exit 1 ; fi
eval set -- "$TEMP"

while true; do
	case "$1" in
		--wheel)
			ARG_WHEEL=$2; shift 2;;
		--cctag)
			ARG_CCTAG=1; shift ;;
		-h|--help)
			print_usage; exit 0 ;;
		--)
			shift; break ;;
		*) echo "Unknown parameter $1"; print_usage; exit 1 ;;
	esac
done
if [[ "$ARG_WHEEL" == "" ]]; then
	print_usage
	exit 1
fi

fullname=$(readlink -f $ARG_WHEEL)
newname=$fullname
tmp=$(mktemp --directory)
pushd $tmp
unzip -q $fullname

if [[ $ARG_CCTAG -eq 1 ]]; then
	tag="+computecanada"
	newname=$(echo $fullname | sed -e "s/\([^-]*\)-\([^-]*\)-\(.*\)\.whl/\1-\2$tag-\3.whl/g")

	# rename the dist-info folder
	distinfo=*dist-info
	newdistinfo=$(echo $distinfo | sed -e "s/\([^-]*\)-\([^-]*\)\(.*\).dist-info/\1-\2$tag\3.dist-info/g")
	mv $distinfo $newdistinfo

	# change the version in the METADATA file
	sed -i -e "s/^Version:\(.*\)\([^ ]*\)\(.*\)/Version:\1\2$tag\3/g" $newdistinfo/METADATA

fi
zip -rq $newname .


popd
rm -rf $tmp

