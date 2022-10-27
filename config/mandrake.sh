PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/bacpop/mandrake/archive/refs/tags/v${VERSION:?version required}.tar.gz"
MODULE_BUILD_DEPS='cuda/11.4 python-build-bundle cmake boost'
PRE_BUILD_COMMANDS='
        export CUDAARCHS=60;70;75;80;86;
'
PATCHES='mandrake-cudaarchs.patch'
