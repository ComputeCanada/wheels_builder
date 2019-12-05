#!/bin/env bash

if [[ -z "$PYTHON_VERSIONS" ]]; then
	PYTHON_VERSIONS=$(ls -1d /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/3* | grep -Po "\d\.\d" | sort -u | sed 's#^#python/#')
fi

PACKAGE=${1?Missing package name}
VERSION=$2
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
PACKAGE_DOWNLOAD_CMD="pip download --no-binary \$PACKAGE_DOWNLOAD_ARGUMENT --no-deps \$PACKAGE_DOWNLOAD_ARGUMENT"

PRE_BUILD_COMMANDS_DEFAULT='sed -i -e "s/\([^\.]\)distutils.core/\1setuptools/g" setup.py'
PYTHON_DEPS="numpy scipy cython"

PYTHON27_ONLY="cogent OBITools gdata qcli emperor RSeQC preprocess Amara pysqlite IPTest ipaddress functools32 blmath bamsurgeon"
if [[ $PYTHON27_ONLY =~ $PACKAGE ]]; then
	PYTHON_VERSIONS="python/2.7"
fi

if [[ -n "$VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE==$VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
fi

if [[ -e "./config/${PACKAGE}-${VERSION}.sh" ]]; then
	source ./config/${PACKAGE}-${VERSION}.sh
elif [[ -e "./config/${PACKAGE}.sh" ]]; then
	source ./config/${PACKAGE}.sh
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

DIR=tmp.$$
mkdir $DIR
pushd $DIR
module --force purge
module load nixpkgs gcc/7.3.0
for pv in $PYTHON_VERSIONS; do
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		module load $MODULE_BUILD_DEPS
	fi
	if [[ -n "$MODULE_RUNTIME_DEPS" ]]; then
		module load $MODULE_RUNTIME_DEPS
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
	virtualenv build_$PVDIR || pyvenv build_$PVDIR
	source build_$PVDIR/bin/activate
	if [[ -n "$PYTHON_DEPS" ]]; then
		pip install $PYTHON_DEPS --find-links=$TMP_WHEELHOUSE
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
		echo "Running /cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path=$RPATH_TO_ADD --any_interpreter"
		/cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path $WHEEL_NAME --add_path $RPATH_TO_ADD --any_interpreter
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
	pip install ../$WHEEL_NAME --no-cache --find-links=$TMP_WHEELHOUSE
	if [[ -n "$PYTHON_IMPORT_NAME" ]]; then
		test_import "$PYTHON_IMPORT_NAME" "$PYTHON_TESTS"
	fi
	SUCCESS=$?
	deactivate
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

echo "Build done, you can now remove $DIR"
echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/[generic,avx2,avx,sse3] and synchronize CVMFS"
