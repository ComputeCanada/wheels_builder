PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/bacpop/PopPUNK/archive/refs/tags/v${VERSION:?version required}.tar.gz"
MODULE_BUILD_DEPS='python-build-bundle cmake eigen flexiblas'
MODULE_RUNTIME_DEPS='graph-tool'
PRE_BUILD_COMMANDS="
        sed -i 's/openblas/flexiblas/' CMakeLists.txt;
"
