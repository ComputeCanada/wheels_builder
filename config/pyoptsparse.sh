PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mdolab/pyoptsparse/archive/refs/tags/v${VERSION?:version required}.tar.gz"
PYTHON_DEPS='meson'
MODULE_BUILD_DEPS="ipopt"
PRE_BUILD_COMMANDS='rm -rf meson_build; export IPOPT_DIR=$EBROOTIPOPT'
# The wheel is not universal
POST_BUILD_COMMANDS="PYVER=\${EBVERSIONPYTHON::-2}; mv \$WHEEL_NAME \${WHEEL_NAME/py3-none-any/cp\${PYVER//.}-cp\${PYVER//.}\$(python3-config --abiflags)-linux_x86_64} && WHEEL_NAME=\$(ls *.whl)"
