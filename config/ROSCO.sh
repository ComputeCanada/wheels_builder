PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/NREL/ROSCO/archive/refs/tags/v${VERSION?:version required}.tar.gz"
PYTHON_DEPS='meson'
BDIST_WHEEL_ARGS='--compile-rosco'
PRE_BUILD_COMMANDS="sed -i -e \"/'numpy',/a 'wisdem',\" -e \"s/^VERSION =.*/VERSION='$VERSION'/\" setup.py;"
PYTHON_IMPORT_NAME='ROSCO_toolbox'
