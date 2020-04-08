#!/bin/env bash

if [[ -z "$PYTHON_VERSIONS" ]]; then
	PYTHON_VERSIONS=$(ls -1d /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/3* | grep -v 3.5 | grep -Po "\d\.\d" | sort -u | sed 's#^#python/#')
fi

TEMP=$(getopt -o h --longoptions help,keep-build-dir,verbose:,recursive:,package:,version:,python: -n $0 -- "$@")
eval set -- "$TEMP"
ARG_RECURSIVE=1
ARG_KEEP_BUILD_DIR=0
ARG_VERBOSE_LEVEL=0
function print_usage {
	echo "Usage: $0 --package <python package name> "
	echo "         [--version <specific version]"
	echo "         [--recursive=<1|0>]"
	echo "         [--python=<comma separated list of python versions>]"
	echo "         [--keep-build-dir]"
	echo "         [--verbose=<1,2,3>]"
}

while true; do
	case "$1" in
		--recursive)
			ARG_RECURSIVE=$2; shift 2;;
		--package)
			ARG_PACKAGE=$2; shift 2;;
		--version)
			ARG_VERSION=$2; shift 2;;
		--python)
			ARG_PYTHON_VERSIONS=$2; shift 2;;
		--keep-build-dir)
			ARG_KEEP_BUILD_DIR=1; shift ;;
		--verbose)
			ARG_VERBOSE_LEVEL=$2; shift 2;;
		-h|--help)
			print_usage; exit 0 ;;
		--) 
			shift; break ;;
		*) echo "Unknown parameter $1"; print_usage; exit 1 ;;
	esac
done
STARTING_DIRECTORY=$(pwd)
PACKAGE=$ARG_PACKAGE
VERSION=$ARG_VERSION
RECURSIVE=$ARG_RECURSIVE

if [[ -z "$PACKAGE" ]]; then
	print_usage
	exit 1
fi

if [[ ! -z "$ARG_PYTHON_VERSIONS" ]]; then
	PYTHON_VERSIONS=""
	for v in ${ARG_PYTHON_VERSIONS//,/ }; do
		PYTHON_VERSIONS="python/$v $PYTHON_VERSIONS"
	done
fi

PYTHON_IMPORT_NAME="$PACKAGE"
PACKAGE_FOLDER_NAME="$PACKAGE"
PACKAGE_DOWNLOAD_NAME="$PACKAGE"
RPATH_TO_ADD=""
BDIST_WHEEL_ARGS=""
PRE_DOWNLOAD_COMMANDS=""
TMP_WHEELHOUSE=$(pwd)
PATCHES=""
# Make sure $PACKAGE_DOWNLOAD_ARGUMENT is not expanded right away
# Do not collect binaries and don't install dependencies
PACKAGE_DOWNLOAD_CMD="pip download --no-cache --no-binary \$PACKAGE_DOWNLOAD_ARGUMENT --no-deps \$PACKAGE_DOWNLOAD_ARGUMENT"
PRE_BUILD_COMMANDS_DEFAULT='sed -i -e "s/\([^\.]\)distutils.core/\1setuptools/g" setup.py'

PYTHON_DEPS_DEFAULT="numpy scipy cython"

PYTHON27_ONLY="cogent OBITools gdata qcli emperor RSeQC preprocess Amara pysqlite IPTest ipaddress functools32 blmath bamsurgeon"
if [[ $PYTHON27_ONLY =~ $PACKAGE ]]; then
	PYTHON_VERSIONS="python/2.7"
fi

if [[ -n "$VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE==$VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
fi

CONFIGDIR=$(dirname $0)/config
if [[ -e "$CONFIGDIR/${PACKAGE}-${VERSION}.sh" ]]; then
	source $CONFIGDIR/${PACKAGE}-${VERSION}.sh
elif [[ -e "$CONFIGDIR/${PACKAGE}.sh" ]]; then
	source $CONFIGDIR/${PACKAGE}.sh
fi

function single_test_import {
	CONST_NAME="$1"
	NAME="$2"
	TESTS="$3"
	if [[ "$NAME" != "$CONST_NAME" ]]; then
		echo "Testing import with name $NAME"
		$PYTHON_CMD -c "import $NAME; $TESTS"
		RET=$?
		test $RET -eq 0  && echo "Sucess!" || echo "Failed"
		return $RET
	else
		return 1
	fi
}
function test_import {
	NAME=$1
	TESTS=$2

	# dashes in names are always replaced by underscore
	NAME=${NAME//-/_}

	CONST_NAME="$NAME"
	echo "Testing import with name $NAME"
	$PYTHON_CMD -c "import $NAME; $TESTS"
	RET=$?
	test $RET -eq 0  && echo "Sucess!" || echo "Failed"

	if [[ $RET -ne 0 ]]; then
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//python_/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//_python/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//py_/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//Py_/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//_py/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//_Py/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//Py/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//py/}"
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME%2}"       #surprisingly, many packages have a name that ends with 2, but import without the 2
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME}2"       #the other way also happens...
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//scikit_/sk}"   #special case for all of the scikit- packages
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//_/.}"   #replacing _ by . sometimes happens
		# add a version of all in lower cases
		NAMES_TO_TEST="$NAMES_TO_TEST ${NAMES_TO_TEST,,}"
		# remove duplicates
		for TEST_NAME in $NAMES_TO_TEST; do
			if [[ ! $NAMES_TO_TEST2 =~ [[:space:]]$TEST_NAME[[:space:]] ]]; then
				NAMES_TO_TEST2=" $NAMES_TO_TEST2 $TEST_NAME "
			fi
		done
		NAMES_TO_TEST=$NAMES_TO_TEST2
		echo "Testing imports with the following names $NAMES_TO_TEST"
		if [[ $RET -ne 0 ]]; then
			RET=1
			for TEST_NAME in $NAMES_TO_TEST; do
				single_test_import "$CONST_NAME" "$TEST_NAME" "$TESTS"
				RET=$?
				if [[ $RET -eq 0 ]]; then break; fi
			done
		fi
	fi
	return $RET

}

function wrapped_pip_install {
	TMPFILE=$RANDOM.out
	if [[ $ARG_VERBOSE_LEVEL -ge 2 ]]; then
		pip install $@ --no-cache --find-links=$TMP_WHEELHOUSE |& tee $TMPFILE
	elif [[ $ARG_VERBOSE_LEVEL -ge 1 ]]; then
		echo Running command: pip install $@ --no-cache --find-links=$TMP_WHEELHOUSE
		pip install $@ --no-cache --find-links=$TMP_WHEELHOUSE &> $TMPFILE
	else
		pip install $@ --no-cache --find-links=$TMP_WHEELHOUSE &> $TMPFILE
	fi
	DOWNLOADED_DEPS=$(grep Downloading $TMPFILE | awk '{print $2}')
	if [[ ! -z "$DOWNLOADED_DEPS" && $RECURSIVE -eq 1 ]]; then
		echo "========================================================="
		echo "The following depencencies were downloaded. Building them: $DOWNLOADED_DEPS"
		for w in $DOWNLOADED_DEPS; do
			echo "========================================================="
			wheel_name=$(basename $w | cut -d'-' -f 1)
			echo Building $wheel_name
			log_command pushd $STARTING_DIRECTORY
			if [[ -z "$ARG_PYTHON_VERSIONS" ]]; then
				./build_wheel.sh --package=$wheel_name --python=$ARG_PYTHON_VERSIONS
			else
				./build_wheel.sh --package=$wheel_name
			fi
			log_command popd
			echo "========================================================="
		done
		echo "Resuming building the main package"
		echo "========================================================="
	fi
	rm $TMPFILE
}

function log_command {
	if [[ $ARG_VERBOSE_LEVEL -ge 1 ]]; then
		echo "Running command: $@"
	fi
	if [[ $ARG_VERBOSE_LEVEL -ge 3 ]]; then
		eval $@ 
	elif [[ $ARG_VERBOSE_LEVEL -ge 2 ]]; then
		eval $@ 2>/dev/null
	else
		eval $@ &>/dev/null
	fi

}

DIR=tmp.$$
mkdir $DIR
log_command pushd $DIR
module --force purge
module load nixpkgs gcc/7.3.0
for pv in $PYTHON_VERSIONS; do
	if [[ $pv =~ python/2 ]]; then
		PYTHON_CMD=python2
	else
		PYTHON_CMD=python3
	fi
	PVDIR=${pv//\//-}

	echo "Loading module $pv"
	log_command module load $pv
	echo "=============================="
	echo "Setting up build environment"
	if [[ -n "$MODULE_RUNTIME_DEPS" ]]; then
		log_command module load $MODULE_RUNTIME_DEPS
	fi
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		log_command module load $MODULE_BUILD_DEPS
	fi
	log_command module list

	log_command python -m venv build_$PVDIR || virtualenv build_$PVDIR || pyvenv build_$PVDIR
	source build_$PVDIR/bin/activate
	log_command pip install --no-index --upgrade pip setuptools wheel
	if [[ -n "$PYTHON_DEPS" ]]; then
		wrapped_pip_install $PYTHON_DEPS_DEFAULT
		wrapped_pip_install $PYTHON_DEPS
	fi
	log_command pip freeze
	echo "=============================="
	echo "=============================="
	if [[ ! -z "$PRE_DOWNLOAD_COMMANDS" ]]; then
		log_command $PRE_DOWNLOAD_COMMANDS
	fi
	echo "Downloading source"
	mkdir $PVDIR
	ARCHNAME=$(eval $PACKAGE_DOWNLOAD_CMD |& tee download.log | grep "Saved " | awk '{print $2}')
	echo "Downloaded $ARCHNAME"
	if [[ ! -z $POST_DOWNLOAD_COMMANDS ]]; then
		log_command $POST_DOWNLOAD_COMMANDS
	fi
#	# skip packages that are already in whl format
	if [[ $ARCHNAME == *.whl ]]; then
		# Patch the content of the wheel file.
		log_command "$PATCH_WHEEL_COMMANDS"
		cp -v $ARCHNAME ..
		continue
	fi
	echo "Extracting archive $ARCHNAME..."
	unzip $ARCHNAME -d $PVDIR &>/dev/null || tar xfv $ARCHNAME -C $PVDIR &>/dev/null
	echo "Extraction done."
	log_command pushd $PVDIR
	log_command pushd $PACKAGE_FOLDER_NAME* || log_command pushd *
	echo "=============================="

	if [[ ! -z "$PATCHES" ]]; then
		echo "=============================="
		echo "Patching"
		for p in $PATCHES;
		do
			log_command patch --verbose -p1 < $p > /dev/null 
		done
		echo "Patching done"
		echo "=============================="
	fi

	echo "=============================="
	echo "Building"
	if [[ "$PACKAGE" == "numpy" ]]; then
		cat << EOF > site.cfg
[mkl]
library_dirs = $MKLROOT/lib/intel64
include_dirs = $MKLROOT/include
mkl_libs = mkl_rt
lapack_libs =
EOF
	fi
	if [[ ! -z "$PRE_BUILD_COMMANDS" ]]; then
		log_command $PRE_BUILD_COMMANDS
	fi
	log_command $PRE_BUILD_COMMANDS_DEFAULT
	# change the name of the wheel to add a suffix
	if [[ -n "$PACKAGE_SUFFIX" ]]; then
		sed -i -e "s/name='$PACKAGE'/name='$PACKAGE$PACKAGE_SUFFIX'/g" $(find . -name "setup.py")
	fi
	echo "Building the wheel...."
	$PYTHON_CMD setup.py bdist_wheel $BDIST_WHEEL_ARGS &> build.log
	if [[ $? -ne 0 ]]; then
		echo "An error occured."
		echo "Build log is in $(pwd)/build.log"
	else
		echo "Success."
	fi
	log_command pushd dist || cat build.log
	WHEEL_NAME=$(ls *.whl)
	log_command "$POST_BUILD_COMMANDS"
	if [[ -n "$RPATH_TO_ADD" ]]; then
		log_command /cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path $RPATH_TO_ADD --any_interpreter
	fi
	cp -v $WHEEL_NAME $TMP_WHEELHOUSE
	log_command popd
	log_command popd
	log_command popd

	rm $ARCHNAME
	echo "Building done"
	echo "=============================="

	echo "=============================="
	echo "Testing..."
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		module unload $MODULE_BUILD_DEPS
	fi
	log_command module list
	echo "Installing wheel"
	wrapped_pip_install ../$WHEEL_NAME
	if [[ -n "$PYTHON_IMPORT_NAME" ]]; then
		test_import "$PYTHON_IMPORT_NAME" "$PYTHON_TESTS"
	fi
	SUCCESS=$?
	deactivate
	chmod o+r ../$WHEEL_NAME
	if [[ $SUCCESS -ne 0 ]]; then
		echo "Error happened"
		cd ..
		exit $SUCCESS
	fi
	echo "Testing done"
	echo "=============================="

	if [[ $WHEEL_NAME =~ .*-py3-.* || $WHEEL_NAME =~ .*py2.py3.* ]]; then
		echo "Wheel is compatible with all further versions of python. Breaking"
		break
	fi
done

log_command popd
if [[ $ARG_KEEP_BUILD_DIR -ne 1 ]]; then
	rm -rf $DIR
fi
echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/[generic,avx2,avx,sse3] and synchronize CVMFS"
