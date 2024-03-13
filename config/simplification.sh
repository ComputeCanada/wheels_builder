# Insanity... it works but requires an external library to be built and copied into the source directory.
MODULE_BUILD_DEPS="rust"
PRE_BUILD_COMMANDS="
    export SETUPTOOLS_SCM_PRETEND_VERSION=${VERSION:?version required};
    git clone --depth 1 --branch v0.12.11 https://github.com/urschrei/rdp.git;
    cd rdp;
    cargo build --release --jobs 8;
    cp -v target/release/librdp.so ../src/simplification/;
    cp -v include/header.h ../src/simplification/;
    cd ..;
"
PYTHON_DEPS="Cython==3.0.8"
