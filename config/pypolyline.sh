# Insanity... it works but requires an external library to be built and copied into the source directory.
MODULE_BUILD_DEPS="rust"
PRE_BUILD_COMMANDS="
    export SETUPTOOLS_SCM_PRETEND_VERSION=${VERSION:?version required};
    git clone --depth 1 --branch v0.6.3 https://github.com/urschrei/polyline-ffi.git;
    cd polyline-ffi;
    cargo build --release --jobs 8;
    cp -v target/release/libpolylineffi.so ../src/pypolyline/;
    cp -v include/header.h ../src/pypolyline/;
    cd ..;
"
PYTHON_DEPS="Cython==3.0.8"
