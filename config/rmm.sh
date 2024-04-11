# The root of repo does not contains a setup nor pyproject. Use git instead.
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/rapidsai/rmm.git"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"

PYTHON_DEPS="scikit-build-core[pyproject]>=0.7.0 cuda-python>=12.0"
MODULE_BUILD_DEPS="cmake cuda/12"
PRE_BUILD_COMMANDS='
    cd python;
    sed -i "s/cuda-python[<=>\.,0-9a]*/cuda-python>=12.0,<13.0a0/g" pyproject.toml;
    export PYTHONPATH=$PYTHONPATH:$VIRTUAL_ENV/lib/python${EBVERSIONPYTHON::-2}/site-packages;
'
