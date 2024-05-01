#!/bin/env bash

THIS_SCRIPT=$0
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$THIS_SCRIPT")")

YEAR="${EBVERSIONGENTOO:-2017}"
EXCLUDE_PYTHON_VERSIONS="/2\.\|/3.[5678]"
OLDEST_SUPPORTED_NUMPY_VERSION=.2022a
if [[ "$YEAR" == "2017" ]]; then
	GCC_VERSION=7.3.0
elif [[ "$YEAR" == "2020" ]]; then
	GCC_VERSION=9.3.0
	CYTHON_VERSION=.0.29.36
else
	GCC_VERSION=12.3
	OLDEST_SUPPORTED_NUMPY_VERSION=.2023b
	EXCLUDE_PYTHON_VERSIONS="/2\.\|/3.[56789]"
	CYTHON_VERSION=.3.0.10
fi

if [[ -z "$PYTHON_VERSIONS" ]]; then
	PYTHON_VERSIONS=$(module --terse spider python | grep -v "$EXCLUDE_PYTHON_VERSIONS" | grep -Po "\d\.\d+" | sort -Vu | sed 's#^#python/#')
fi

function print_usage {
	echo "Usage: $0 --package <python package name> "
	echo "         [--version <specific version]"
	echo "         [--recursive=<1|0>]"
	echo "         [--python=<comma separated list of python versions>]"
	echo "         [--keep-build-dir]"
	echo "         [--verbose=<1,2,3>]"
}

# Translate a version number into a comparable number, supports up to 4 digits
# Supports : 4.24, 4.24.0, 4.24.0.0 which all translate to 4024000000
function translate_version {
	echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

TEMP=$(getopt -o h --longoptions help,keep-build-dir,autocopy,verbose:,recursive:,package:,version:,python: -n $0 -- "$@")
if [ $? != 0 ] ; then print_usage; exit 1 ; fi
eval set -- "$TEMP"

ARG_RECURSIVE=1
ARG_KEEP_BUILD_DIR=0
ARG_VERBOSE_LEVEL=0
ARG_AUTOCOPY=0
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
		--autocopy)
			ARG_AUTOCOPY=1; shift ;;
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
UPDATE_REQUIREMENTS=""
RPATH_TO_ADD=""
BDIST_WHEEL_ARGS=""
PIP_WHEEL_ARGS=""
PRE_DOWNLOAD_COMMANDS=""
TMP_WHEELHOUSE=$(pwd)
PATCHES=""
# Make sure $PACKAGE_DOWNLOAD_ARGUMENT is not expanded right away
# Do not collect binaries and don't install dependencies
PACKAGE_DOWNLOAD_CMD="pip download -v --no-cache --no-binary \$PACKAGE --no-use-pep517 --no-build-isolation --no-deps \$PACKAGE_DOWNLOAD_ARGUMENT"
PRE_BUILD_COMMANDS_DEFAULT='sed -i -e "s/\([^\.]\)distutils.core/\1setuptools/g" setup.py'

PYTHON_DEPS_DEFAULT=""
MODULE_BUILD_DEPS_DEFAULT="oldest-supported-numpy/$OLDEST_SUPPORTED_NUMPY_VERSION python-build-bundle pytest/7.4.0 cython/$CYTHON_VERSION"

PYTHON27_ONLY="cogent OBITools gdata qcli emperor RSeQC preprocess Amara pysqlite IPTest ipaddress functools32 blmath bamsurgeon"
if [[ $PYTHON27_ONLY =~ " $PACKAGE " ]]; then
	PYTHON_VERSIONS="python/2.7"
fi

if [[ -n "$VERSION" ]]; then
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE==$VERSION"
else
	PACKAGE_DOWNLOAD_ARGUMENT="$PACKAGE"
fi

CONFIGDIR=$SCRIPT_DIR/config
if [[ -e "$CONFIGDIR/${PACKAGE}-${VERSION}.sh" ]]; then
	source $CONFIGDIR/${PACKAGE}-${VERSION}.sh
	echo "INFO: Sourced configuration $CONFIGDIR/${PACKAGE}-${VERSION}.sh"
elif [[ -e "$CONFIGDIR/${PACKAGE}.sh" ]]; then
	source $CONFIGDIR/${PACKAGE}.sh
	echo "INFO: Sourced configuration $CONFIGDIR/${PACKAGE}.sh"
else
	echo "INFO: no configuration file sourced."
fi

# define some ANSI sequences for colorful output.
COL_RED="\033[31;1m" # red
COL_GRN="\033[32;1m" # green
COL_YEL="\033[33;1m" # yellow
COL_RST="\033[0m" # reset

function single_test_import {
	CONST_NAME="$1"
	NAME="$2"
	TESTS="$3"
	FORCE=$4
	if [[ "$NAME" != "$CONST_NAME" || $FORCE -eq 1 ]]; then
		echo -n "Testing import with name $NAME... "
		if [[ $ARG_VERBOSE_LEVEL -gt 1 ]]; then
			$PYTHON_CMD -c "import $NAME; $TESTS"
			RET=$?
		else
			$PYTHON_CMD -c "import $NAME; $TESTS" 2>/dev/null
			RET=$?
		fi
		test $RET -eq 0  && echo -e "${COL_GRN}Success!${COL_RST}" || echo "Failed"
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
	single_test_import "$CONST_NAME" "$NAME" "$TESTS" 1
	RET=$?

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
		NAMES_TO_TEST="$NAMES_TO_TEST ${CONST_NAME//_/}"   #remove _ sometimes happens
		# add a version of all in lower cases
		NAMES_TO_TEST="$NAMES_TO_TEST ${NAMES_TO_TEST,,}"
		# add a version of all in upper cases
		NAMES_TO_TEST="$NAMES_TO_TEST ${NAMES_TO_TEST^^}"
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
		echo Running command: pip install $@ --no-cache --find-links=$TMP_WHEELHOUSE
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
		echo "The following dependencies were downloaded. Building them: $DOWNLOADED_DEPS"
		for w in $DOWNLOADED_DEPS; do
			echo "========================================================="
			wheel_name=$(basename $w | grep -Po '^[\w_-]+-' | sed 's/.$//')
			wheel_version=$(basename $w | cut -d'-' -f2 | cut -d'+' -f1 | sed -e "s/.tar.gz$//")
			echo Building $wheel_name
			log_command pushd $STARTING_DIRECTORY
			echo $w
			if [[ $w =~ .*none-any.* ]]; then
				IS_NONE_ANY="yes"
			else
				IS_NONE_ANY="no"
			fi
			if [[ -e "$CONFIGDIR/${wheel_name}-${wheel_version}.sh" || -e "$CONFIGDIR/${wheel_name}.sh" || "${IS_NONE_ANY}" == "no"  ]]; then
				if [[ ! -z "$ARG_PYTHON_VERSIONS" ]]; then
					log_command bash $THIS_SCRIPT --package=$wheel_name --version $wheel_version --recursive=0 --python=$ARG_PYTHON_VERSIONS --verbose=$ARG_VERBOSE_LEVEL
				else
					log_command bash $THIS_SCRIPT --package=$wheel_name --version $wheel_version --recursive=0 --verbose=$ARG_VERBOSE_LEVEL
				fi
			else
				echo "Wheel is none-any, using unmanylinuxize.sh"
				log_command bash ./unmanylinuxize.sh --package $wheel_name --version $wheel_version
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

function setup()
{
	echo "=============================="
	echo "Setting up build environment"
	if [[ -n "$MODULE_RUNTIME_DEPS" ]]; then
		log_command module load $MODULE_RUNTIME_DEPS
	fi
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		log_command module load $MODULE_BUILD_DEPS
	fi
	if [[ ! -z "$PRE_SETUP_COMMANDS" ]]; then
		log_command $PRE_SETUP_COMMANDS
	fi
	log_command module list

	log_command python -m venv build_$PVDIR || virtualenv build_$PVDIR || pyvenv build_$PVDIR
	source build_$PVDIR/bin/activate
	if [[ -n "$PYTHON_DEPS_DEFAULT" ]]; then
		wrapped_pip_install $PYTHON_DEPS_DEFAULT
	fi
	if [[ -n "$PYTHON_DEPS" ]]; then
		wrapped_pip_install $PYTHON_DEPS
	fi
	log_command pip freeze
	echo "=============================="
}

function download()
{
	echo "=============================="
	if [[ ! -z "$PRE_DOWNLOAD_COMMANDS" ]]; then
		log_command $PRE_DOWNLOAD_COMMANDS
	fi
	echo "Downloading source"
	mkdir $PVDIR
	ARCHNAME=$(PIP_CONFIG_FILE= eval $PACKAGE_DOWNLOAD_CMD |& tee download.log | grep "Saved " | awk '{print $2}')
	if [[ $PACKAGE_DOWNLOAD_METHOD == "Git" ]]; then
		ARCHNAME=$PACKAGE_DOWNLOAD_NAME
	fi
	if [[ -z "$ARCHNAME" ]]; then
		grep -l "Disabling PEP 517 processing" $PWD/download.log
		if [[ $? -eq 0 ]]; then
			echo "Package $PACKAGE_DOWNLOAD_NAME does not support disabling PEP 517. Trying again without --no-use-pep517"
			PACKAGE_DOWNLOAD_CMD=${PACKAGE_DOWNLOAD_CMD//--no-use-pep517/}
			ARCHNAME=$(PIP_CONFIG_FILE= eval $PACKAGE_DOWNLOAD_CMD |& tee download.log | grep "Saved " | awk '{print $2}')
		fi
	fi
	if [[ -z "$ARCHNAME" ]]; then
		echo "Trying to download without --no-binary to see if it is a py3-none-any wheel."
		PACKAGE_DOWNLOAD_CMD=${PACKAGE_DOWNLOAD_CMD//--no-binary \$PACKAGE/}
		PACKAGE_DOWNLOAD_CMD=${PACKAGE_DOWNLOAD_CMD//--no-use-pep517/}
		ARCHNAME=$(PIP_CONFIG_FILE= eval $PACKAGE_DOWNLOAD_CMD |& tee download.log | grep "Saved " | awk '{print $2}')
		if [[ $ARCHNAME =~ .*-py3-none-any.* ]]; then
			echo $ARCHNAME is py3-none-any, no build needed
		else
			unset $ARCHNAME
		fi

	fi
	echo "Downloaded '$ARCHNAME'"
	if [[ -z "$ARCHNAME" ]]; then
		echo -e "${COL_RED}Error while downloading package. Aborting...${COL_RST}"
		echo "See : $PWD/download.log"
		exit 1
	fi
	if [[ ! -z $POST_DOWNLOAD_COMMANDS ]]; then
		log_command $POST_DOWNLOAD_COMMANDS
	fi
	echo "=============================="
}

function verify_and_patch_arch_flags()
{
	echo "=============================="
	echo "Testing source code for CPU architecture instructions in $PWD"
	files_native=$(grep -rl -- "-march=native" .)
	files_xHost=$(grep -rl -- "-xHost" .)
	if [[ -n "$files_native" ]]; then
		declare -A gcc_targets
		gcc_targets=(
			["avx"]="corei7-avx"
			["avx2"]="core-avx2"
			["avx512"]="skylake-avx512"
			["sse3"]="nocona"
		)
		target=${gcc_targets[$RSNT_ARCH]}
		ARCH_PRESENCE=$RSNT_ARCH
		if [[ "$YEAR" == "2023" ]]; then
			gcc_targets["avx2"]="x86-64-v3"
			gcc_targets["avx512"]="x86-64-v4"
			target=${gcc_targets[$RSNT_ARCH]}
			ARCH_PRESENCE=$target
		fi
		echo "-march=native found in files $files_native, replacing with -march=$target to build for $RSNT_ARCH"
		sed -i -e "s/-march=native/-march=$target/" $files_native
	fi
	if [[ -n "$files_xHost" ]]; then
		echo "NOTE: -xHost found in files $files_xHost, expecting to be built with Intel compiler ?"
	fi
	echo "=============================="
}
function patch_function()
{
	PATCHESDIR=$SCRIPT_DIR/patches
	if [[ ! -z "$PATCHES" ]]; then
		echo "=============================="
		echo "Patching"
		for p in $PATCHES;
		do
			log_command patch --verbose -p1 < ${PATCHESDIR}/$p > /dev/null
		done
		echo "Patching done"
		echo "=============================="
	fi
}

function build()
{
	echo "=============================="
	echo "Building"
	if [[ ! -z "$PRE_BUILD_COMMANDS" ]]; then
		log_command $PRE_BUILD_COMMANDS
	fi
	log_command $PRE_BUILD_COMMANDS_DEFAULT
	
	verify_and_patch_arch_flags

	# change the name of the wheel to add a suffix
	if [[ -n "$PACKAGE_SUFFIX" ]]; then
		sed -i -e "s/name=\"$PACKAGE\"/name=\"$PACKAGE$PACKAGE_SUFFIX\"/g" -e "s/name='$PACKAGE'/name='$PACKAGE$PACKAGE_SUFFIX'/g" $(find . -name "setup.py")
	fi
	echo "Building the wheel...."
	if [[ -f "pyproject.toml" ]]; then
		log_command pip wheel -vvv --no-deps --no-build-isolation $PIP_WHEEL_ARGS . &> build.log
	elif [[ -f "setup.py" ]]; then
		log_command $PYTHON_CMD setup.py bdist_wheel $BDIST_WHEEL_ARGS &> build.log
	fi
	if [[ $? -ne 0 ]]; then
		echo -e "${COL_RED}An error occured.${COL_RST}"
		echo "Build log is in $(pwd)/build.log"
	else
		echo -e "${COL_GRN}Success.${COL_RST}"
	fi

	if [[ -d dist ]]; then
		log_command cp dist/*.whl . 
	fi

	WHEEL_NAME=$(ls *.whl)
	if [[ -z $WHEEL_NAME ]]; then
		cat build.log
	fi
	# add a computecanada local_version
	if [[ -z "$UPDATE_REQUIREMENTS" ]]; then
		log_command $SCRIPT_DIR/manipulate_wheels.py --insert_local_version --inplace --wheels $WHEEL_NAME && rm $WHEEL_NAME
	else
		log_command $SCRIPT_DIR/manipulate_wheels.py -v --insert_local_version --inplace --wheels $WHEEL_NAME --update_req $UPDATE_REQUIREMENTS && rm $WHEEL_NAME
	fi
	WHEEL_NAME=$(ls *.whl)
	log_command "$POST_BUILD_COMMANDS"
	if [[ -n "$RPATH_TO_ADD" || -n "$RPATH_ADD_ORIGIN" ]]; then
		setrpaths_cmd="/cvmfs/soft.computecanada.ca/easybuild/bin/setrpaths.sh --path ${WHEEL_NAME}"
		if [[ ! -z "$RPATH_TO_ADD" ]]; then
			setrpaths_cmd="${setrpaths_cmd} --add_path ${RPATH_TO_ADD} --any_interpreter"
		fi
		if [[ ! -z "$RPATH_ADD_ORIGIN" ]]; then
			setrpaths_cmd="${setrpaths_cmd} --add_origin"
		fi
		log_command $setrpaths_cmd
	fi

	log_command cp -v $WHEEL_NAME $TMP_WHEELHOUSE
	echo "Building done"
	echo "=============================="
}

function test_whl()
{
	echo "=============================="
	echo "Testing..."
	deactivate
	if [[ -n "$MODULE_BUILD_DEPS" ]]; then
		module unload $MODULE_BUILD_DEPS
	fi
	if [[ -n "$MODULE_RUNTIME_DEPS" ]]; then
		module load $MODULE_RUNTIME_DEPS
	fi
	source build_$PVDIR/bin/activate
	log_command module list
	echo "Installing wheel"
	wrapped_pip_install ../$WHEEL_NAME
	if [[ ! -z "$PRE_TEST_COMMANDS" ]]; then
		log_command $PRE_TEST_COMMANDS
	fi
	if [[ -n "$TEST_COMMAND" ]]; then
		log_command $TEST_COMMAND
	elif [[ -n "$PYTHON_IMPORT_NAME" ]]; then
		test_import "$PYTHON_IMPORT_NAME" "$PYTHON_TESTS"
	fi
	SUCCESS=$?
	deactivate
	chmod o+r ../$WHEEL_NAME
	if [[ $SUCCESS -ne 0 ]]; then
		echo -e "${COL_RED}Error happened${COL_RST}"
		cd ..
		exit $SUCCESS
	fi
	echo "Testing done"
	echo "=============================="
}

function adjust_numpy_requirements_based_on_link_info()
{
	# don't modify numpy wheels themselves
	if [[ $WHEEL_NAME =~ ^numpy-.* ]]; then
		return
	fi
	# only linux_x86_64 wheels will contain .so'
	if [[ $WHEEL_NAME =~ .*linux_x86_64.* ]]; then
		tmpdir=/tmp/wheel_builder_$BASHPID_$RANDOM
		mkdir $tmpdir && pushd $tmpdir
		log_command unzip -qn $TMP_WHEELHOUSE/$WHEEL_NAME
		num_so=$(find . -name '*.so' | wc -l)
		if [[ $num_so -gt 0 ]]; then
			num_links=$(grep -l "module compiled against API version .* but this version of numpy is .*" $(find . -name '*.so') | wc -l)
		else
			num_links=0
		fi
		popd
		rm -rf $tmpdir
		if [[ $num_links -gt 0 ]]; then
			numpy_build_version=$(pip show numpy | grep Version | awk '{print $2}' | sed -e "s/\([0-9]\.[0-9]*\)\..*/\1/g")
			echo "Found $num_links shared objects that mention a specific version of API of numpy. Pinning the minimum required version of numpy to $numpy_build_version"
			if [[ $(grep -ic $PACKAGE $SCRIPT_DIR/packages_w_numpy_api.txt) -eq 0 ]]; then
				echo "Recording '$PACKAGE' in 'packages_w_numpy_api.txt'."
				echo "$PACKAGE" >> $SCRIPT_DIR/packages_w_numpy_api.txt
				echo -e "${COL_YEL}Please commit the file 'packages_w_numpy_api.txt'.${COL_RST}"
			fi
			log_command $SCRIPT_DIR/manipulate_wheels.py --print_req --wheels $TMP_WHEELHOUSE/$WHEEL_NAME
			log_command $SCRIPT_DIR/manipulate_wheels.py --inplace --force --wheels $TMP_WHEELHOUSE/$WHEEL_NAME --set_min_numpy $numpy_build_version
			log_command $SCRIPT_DIR/manipulate_wheels.py --print_req --wheels $TMP_WHEELHOUSE/$WHEEL_NAME
		fi
	fi
}

function adjust_torch_requirements_based_on_link_info()
{
	# don't modify torch wheels themselves
	if [[ $WHEEL_NAME =~ ^torch-.* ]]; then
		return
	fi

	# only linux_x86_64 wheels will contain .so'
	if [[ $WHEEL_NAME =~ .*linux_x86_64.* ]]; then
		echo "Testing if wheel links on libtorch..."
		local tmpdir=$(mktemp -d)
		log_command unzip -qn $TMP_WHEELHOUSE/$WHEEL_NAME -d $tmpdir
		find $tmpdir -type f -executable -exec ldd {} \+ | fgrep 'libtorch.so'
		local res=$?

		if [[ $res -eq 0 || ! -z "$TORCH_VERSION" ]]; then
			echo "Link dependency on libtorch found. Pinning version of torch"
			torch_build_version=$(pip show torch | grep Version | awk '{print $2}' | sed -e "s/\([^+]*\)+*.*/\1/g")
			torch_build_version=${torch_build_version::-2} # X.Y.Z -> X.Y
			log_command $SCRIPT_DIR/manipulate_wheels.py --print_req --wheels $TMP_WHEELHOUSE/$WHEEL_NAME

			# Some wheels depends on torch but do not has the requirement, add it or update it.
			has_torch_req=$(log_command $SCRIPT_DIR/manipulate_wheels.py --print_req --wheels $TMP_WHEELHOUSE/$WHEEL_NAME | grep -cE '^torch$')
			if [[ $has_torch_req -eq 0 ]]; then
				log_command $SCRIPT_DIR/manipulate_wheels.py --inplace --force --wheels $TMP_WHEELHOUSE/$WHEEL_NAME --add_req "\"torch (~=${torch_build_version}.0)\""
			else
				# Pin compatible version: ~=1.12.0 -> upmost micro version we currently have.
				log_command $SCRIPT_DIR/manipulate_wheels.py --inplace --force --wheels $TMP_WHEELHOUSE/$WHEEL_NAME --update_req "\"torch (~=${torch_build_version}.0)\""
			fi
			log_command $SCRIPT_DIR/manipulate_wheels.py --print_req --wheels $TMP_WHEELHOUSE/$WHEEL_NAME

			# Does it need to be tagged, would it override an existing wheel of the same version?
			local wheel_pattern=$(echo ${WHEEL_NAME//+computecanada/-} | sed -e 's/--/\*/')
			if [[ $(find /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/ -name "${wheel_pattern}" | wc -l) -gt 0 ]]; then
				echo "Found existing wheel that would have been overriden. Tagging the wheel."
				local tag="torch${torch_build_version//./}"
				log_command $SCRIPT_DIR/manipulate_wheels.py --inplace --force --wheels $TMP_WHEELHOUSE/$WHEEL_NAME --add_tag $tag

				local new_wheel=${WHEEL_NAME//+computecanada/+$tag.computecanada}
				rm $TMP_WHEELHOUSE/$WHEEL_NAME
				WHEEL_NAME=$new_wheel
			fi
		else
			echo "No link dependency on libtorch found."
		fi
	fi
}

echo "Building wheel for $PACKAGE"
DIR=tmp.$$
mkdir $DIR
log_command pushd $DIR
if [[ -z "$EBROOTGENTOO" ]]; then
	module --force purge
	module load nixpkgs gcc/$GCC_VERSION
else
	ARCH_TO_LOAD="$EBVERSIONARCH"
	# Figure out cheaply if the wheel needs an arch module to build
	for mod in $MODULE_BUILD_DEPS; do
		if [[ "${mod##arch/}" != "$mod" ]]; then
		       ARCH_TO_LOAD="${mod##arch/}"
		fi
	done
	module --force purge
	# if there are module dependencies, we really should build with our primary architecture rather than the compatibility one
	if [[ -z "$MODULE_BUILD_DEPS" && -z "$MODULE_RUNTIME_DEPS" && "$YEAR" == "2020" ]]; then
		module load arch/${ARCH_TO_LOAD:-sse3}
	else
		module load arch/${ARCH_TO_LOAD:-avx2}
	fi
	log_command module load gentoo/$YEAR gcc/$GCC_VERSION $MODULE_BUILD_DEPS_DEFAULT
fi
for pv in $PYTHON_VERSIONS; do
	if [[ $pv =~ python/2 ]]; then
		PYTHON_CMD=python2
	else
		PYTHON_CMD=python3
	fi
	PVDIR=${pv//\//-}

	echo "Loading module $pv"
	log_command module load $pv
	log_command module load $MODULE_BUILD_DEPS_DEFAULT

	setup

	download

#	# skip packages that are already in whl format
	if [[ $ARCHNAME == *.whl ]]; then
		# Patch the content of the wheel file.
		log_command "$PATCH_WHEEL_COMMANDS"
		# add a computecanada local_version
		$SCRIPT_DIR/manipulate_wheels.py --insert_local_version --wheels $ARCHNAME --inplace && rm $ARCHNAME
		WHEEL_NAME=$(ls *.whl)
		cp -v $WHEEL_NAME $TMP_WHEELHOUSE
	else
		echo "Extracting archive $ARCHNAME..."
		unzip $ARCHNAME -d $PVDIR &>/dev/null || tar xfv $ARCHNAME -C $PVDIR &>/dev/null
		echo "Extraction done."
		log_command pushd $PVDIR
		log_command pushd $PACKAGE_FOLDER_NAME* || log_command pushd *
		
		patch_function

		build

		log_command popd
		log_command popd

		rm $ARCHNAME
	fi

	adjust_numpy_requirements_based_on_link_info
	adjust_torch_requirements_based_on_link_info
	
	test_whl

	if [[ $WHEEL_NAME =~ .*-py3-.* || $WHEEL_NAME =~ .*py2.py3.* ]]; then
		echo "Wheel $WHEEL_NAME is compatible with all further versions of python. Breaking"
		break
	fi
done

log_command popd
if [[ $ARG_KEEP_BUILD_DIR -ne 1 ]]; then
	rm -rf $DIR
fi

if [[ ! -z "$ARCH_PRESENCE" ]]; then
	echo -e "${COL_YEL}WARNING: ${PACKAGE} was built for ${ARCH_PRESENCE}.${COL_RST}"
	echo "The wheel can be copied with : $SCRIPT_DIR/cp_wheels.sh --remove --arch $ARCH_PRESENCE"
fi

if [[ $ARG_AUTOCOPY -ne 1 ]]; then
	echo "If you are satisfied with the built wheel, you can copy them to /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/[generic,avx2,avx,sse3] and synchronize CVMFS"
else
	$SCRIPT_DIR/cp_wheels.sh --remove
fi
