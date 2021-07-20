#!/bin/env bash

THIS_SCRIPT=$0

function print_usage
{
	echo "Usage: $0 --wheel <wheel file> [--local_version]"
	echo "  --local_version will add a '+computecanada' local version ot the wheel"
	echo "  --update_req <requirement value> will update requirements."
	echo "    for example: --update_req \"numpy (<1.23.0,>=1.20.0)\""
	echo "    Warning: make sure to use the correct syntax"
}
function cleanup {
	rm -rf $tmp
}
TEMP=$(getopt -o h --longoptions help,wheel:,local_version,update_req: --name $0 -- "$@")
if [ $? != 0 ] ; then print_usage; exit 1 ; fi
eval set -- "$TEMP"

while true; do
	case "$1" in
		--wheel)
			ARG_WHEEL=$2; shift 2;;
		--local_version)
			ARG_LOCAL_VERSION=1; shift ;;
		--update_req)
			ARG_UPDATE_REQUIREMENTS=1;
			ARG_REQUIREMENTS_NEW_VALUE="$2"; shift 2;;
		-h|--help)
			print_usage; exit 0 ;;
		--)
			shift; break ;;
		*) echo "Unknown parameter $1"; print_usage; exit 1 ;;
	esac
done
if [[ "$ARG_WHEEL" == "" ]]; then
	print_usage
	exit 1
fi

filepath=$(readlink -f $ARG_WHEEL)
new_filepath=$filepath
tmp=$(mktemp --directory)
cd $tmp 
unzip -q $filepath


if [[ $ARG_LOCAL_VERSION -eq 1 ]]; then
	local_version="computecanada"
	filename=$(basename $filepath)
	# split by -
	components=(${filename//-/ })
	name=${components[0]}
	version=${components[1]}

	# check if the version already contains a local version, if so, add to it with . separator
	if [[ $version =~ .*\+.* ]]; then
		if [[ $version =~ .*\+$local_version.* ]]; then
			echo "This wheel already has the computecanada local version. Skipping"
			cleanup
			exit 1
		fi
		new_version="$version.$local_version"
	else
		new_version="$version+$local_version"
	fi

	new_filepath=$(echo $filepath | sed -e "s/$name-$version-\(.*\).whl/$name-$new_version-\1.whl/g")

	# rename the dist-info folder
	distinfo=*dist-info
	newdistinfo=$(echo $distinfo | sed -e "s/$name-$version\(.*\).dist-info/$name-$new_version\1.dist-info/g")
	mv $distinfo $newdistinfo

	# change the version in the METADATA file
	sed -i -e "s/^Version: $version/Version: $new_version/g" $newdistinfo/METADATA

fi
if [[ $ARG_UPDATE_REQUIREMENTS -eq 1 ]]; then
	WORDS=(${ARG_REQUIREMENTS_NEW_VALUE})
	ARG_REQUIREMENTS_SOURCE_PATTERN=${WORDS[0]}
	distinfo=*dist-info
	# update the requirement
	sed -i -e "s/Requires-Dist: $ARG_REQUIREMENTS_SOURCE_PATTERN.*/Requires-Dist: $ARG_REQUIREMENTS_NEW_VALUE/g" $distinfo/METADATA
fi
zip -rq $new_filepath .


cd -
cleanup


