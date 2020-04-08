#!/bin/env bash

if [[ -z "$PYTHON_VERSIONS" ]]; then
	PYTHON_VERSIONS=$(ls -1d /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/3* | grep -v 3.5 | grep -Po "\d\.\d" | sort -u | sed 's#^#python/#')
fi

TEMP=$(getopt -o h --longoptions help,keep-build-dir,recursive:,package:,version:,python: -n $0 -- "$@")
eval set -- "$TEMP"
ARG_RECURSIVE=1
ARG_KEEP_BUILD_DIR=0
function print_usage {
	echo "Usage: $0 --package <python package name> "
	echo "         [--version <specific version]"
	echo "         [--recursive=<1|0>]"
	echo "         [--python=<comma separated list of python versions>]"
	echo "         [--keep-build-dir]"
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
	pip install $@ --no-cache --find-links=$TMP_WHEELHOUSE |& tee $TMPFILE
	DOWNLOADED_DEPS=$(grep Downloading $TMPFILE | awk '{print $2}')
	if [[ ! -z "$DOWNLOADED_DEPS" && $RECURSIVE -eq 1 ]]; then
		echo "========================================================="
		echo "The following depencencies were downloaded. Building them: $DOWNLOADED_DEPS"
		for w in $DOWNLOADED_DEPS; do
			echo "========================================================="
			wheel_name=$(basename $w | cut -d'-' -f 1)
			echo Building $wheel_name
			pushd $STARTING_DIRECTORY
			if [[ -z "$ARG_PYTHON_VERSIONS" ]]; then
				./build_wheel.sh --package=$wheel_name --python=$ARG_PYTHON_VERSIONS
			else
				./build_wheel.sh --package=$wheel_name
			fi
			popd
			echo "========================================================="
		done
		echo "Resuming building the main package"
		echo "========================================================="
	fi
	rm $TMPFILE
}
PYTHON_DEPS="$PYTHON_DEPS $PYTHON_DEPS_DEFAULT"

DIR=tmp.$$
mkdir $DIR
pushd $DIR
module --force purge
module load nixpkgs gcc/7.3.0
for pv in $PYTHON_VERSIONS; do
	if [[ -n "$MODULE_RUNTIME_DEPS" ]]; then
		module load $MODULE_RUNTIME_DEPS
	fi
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		module load $MODULE_BUILD_DEPS
	fi
	module load $pv
	module list

	if [[ $pv =~ python/2 ]]; then
		PYTHON_CMD=python2
	else
		PYTHON_CMD=python3
	fi
	PVDIR=${pv//\//-}

	echo "Setting up build environment"
	python -m venv build_$PVDIR || virtualenv build_$PVDIR || pyvenv build_$PVDIR
	source build_$PVDIR/bin/activate
	pip install --no-index --upgrade pip setuptools wheel
	if [[ -n "$PYTHON_DEPS" ]]; then
		wrapped_pip_install $PYTHON_DEPS
	fi
	pip freeze
	eval $PRE_DOWNLOAD_COMMANDS
	echo "Downloading source"
	mkdir $PVDIR
	eval $PACKAGE_DOWNLOAD_CMD
	eval $POST_DOWNLOAD_COMMANDS
	if [[ $PACKAGE_DOWNLOAD_NAME =~ (.zip|.tar.gz|.tgz|.whl|.tar.bz2)$ ]]; then
		ARCHNAME="$PACKAGE_DOWNLOAD_NAME"
	else
		ARCHNAME=$(ls $PACKAGE_DOWNLOAD_NAME-[0-9]*{.zip,.tar.gz,.tgz,.whl,.tar.bz2})
	fi
	# skip packages that are already in whl format
	if [[ $ARCHNAME == *.whl ]]; then
		# Patch the content of the wheel file.
		eval "$PATCH_WHEEL_COMMANDS"
		cp -v $ARCHNAME ..
		continue
	fi
	unzip $ARCHNAME -d $PVDIR || tar xfv $ARCHNAME -C $PVDIR
	pushd $PVDIR
	pushd $PACKAGE_FOLDER_NAME*

	echo "Patching"
	for p in $PATCHES;
	do
		patch --verbose -p1 < $p
	done

	echo "Building"
	pwd
	ls
	module list
	which $PYTHON_CMD
	if [[ "$PACKAGE" == "numpy" ]]; then
		cat << EOF > site.cfg
[mkl]
library_dirs = $MKLROOT/lib/intel64
include_dirs = $MKLROOT/include
mkl_libs = mkl_rt
lapack_libs =
EOF
	fi
	eval $PRE_BUILD_COMMANDS
	eval $PRE_BUILD_COMMANDS_DEFAULT
	# change the name of the wheel to add a suffix
	if [[ -n "$PACKAGE_SUFFIX" ]]; then
		sed -i -e "s/name='$PACKAGE'/name='$PACKAGE$PACKAGE_SUFFIX'/g" $(find . -name "setup.py")
	fi
	$PYTHON_CMD setup.py bdist_wheel $BDIST_WHEEL_ARGS |& tee build.log
	pushd dist || cat build.log
	WHEEL_NAME=$(ls *.whl)
	eval "$POST_BUILD_COMMANDS"
	if [[ -n "$RPATH_TO_ADD" ]]; then
		eval echo "Running /cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path=$RPATH_TO_ADD --any_interpreter"
		eval /cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path $RPATH_TO_ADD --any_interpreter
	fi
	pwd
	ls
	cp -v $WHEEL_NAME $TMP_WHEELHOUSE
	popd
	popd
	popd

	echo "Testing..."
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		module unload $MODULE_BUILD_DEPS
	fi
	module list
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

	if [[ $WHEEL_NAME =~ .*-py3-.* || $WHEEL_NAME =~ .*py2.py3.* ]]; then
		echo "Wheel is compatible with all further versions of python. Breaking"
		break
	fi
done

popd
if [[ $ARG_KEEP_BUILD_DIR -ne 1 ]]; then
	rm -rf $DIR
fi
echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/[generic,avx2,avx,sse3] and synchronize CVMFS"
