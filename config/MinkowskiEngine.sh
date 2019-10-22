PYTHON_VERSIONS="python/3.6 python/3.7"
MODULE_BUILD_DEPS="cuda/10 imkl"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/StanfordVL/MinkowskiEngine/archive/master.zip"
PACKAGE_DOWNLOAD_NAME="master.zip"
PRE_BUILD_COMMANDS='sed -i -e "s/make /make BLAS=mkl /g" -e "s/, .openblas.//g" $(find . -name "setup.py")'
PYTHON_DEPS="torch"

