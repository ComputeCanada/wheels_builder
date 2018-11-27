#!/usr/bin/env bash
# Source
# https://github.com/protocolbuffers/protobuf/blob/3.6.x/python/release/wheel/protobuf_optimized_pip.sh
# Modified to patch a bug with std C++11 
# Modified to wor with compute canada stack
# Patcher : Félix-Antoine Fortin

set -ex
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Print usage and fail.
function usage() {
  echo "Usage: protobuf_optimized_pip.sh PROTOBUF_VERSION" >&2
  exit 1   # Causes caller to exit because we use -e.
}

# Build wheel
function build_wheel() {
  PYTHON_VERSION=$1
  module load python/$1
  PYTHON_BIN=$(which python)

  CFLAGS="-std=c++11" $PYTHON_BIN setup.py bdist_wheel --cpp_implementation --compile_static_extension
}

# Validate arguments.
if [ $0 != ./protobuf_optimized_pip.sh ]; then
  echo "Please run this script from the directory in which it is located." >&2
  exit 1
fi

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

PROTOBUF_VERSION=$1

DIR=${PWD}/'protobuf-python-build'
PYTHON_VERSIONS=('2.7' '3.5' '3.6')

mkdir -p ${DIR}
cd ${DIR}
curl -SsL -O https://github.com/protocolbuffers/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz
tar xzf v${PROTOBUF_VERSION}.tar.gz
cd $DIR/protobuf-${PROTOBUF_VERSION}

# Autoconf on centos 5.11 cannot recognize AC_PROG_OBJC.
sed -i '/AC_PROG_OBJC/d' configure.ac
sed -i 's/conformance\/Makefile//g' configure.ac

# Use the /usr/bin/autoconf and related tools to pick the correct aclocal macros

module load gcc/5.4.0

# Build protoc
./autogen.sh
CXXFLAGS="-fPIC -g -O2 -std=c++11" ./configure
make -j8
export PROTOC=$DIR/src/protoc

cd python

for PYTHON_VERSION in "${PYTHON_VERSIONS[@]}"
do
  build_wheel $PYTHON_VERSION
done

cp dist/*.whl $SCRIPT_DIR
