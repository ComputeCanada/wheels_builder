PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/whatshap/whatshap.git@v${VERSION:?version required}"
PRE_BUILD_COMMANDS="
        export SETUPTOOLS_SCM_PRETEND_VERSION=${VERSION:?version required};
"
