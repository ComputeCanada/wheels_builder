if [[ -n $EBROOTGENTOO ]] ; then
    MODULE_RUNTIME_DEPS="gcc/9.3.0 openmpi/4.0.3 openmm/7.7.0"
else
    MODULE_RUNTIME_DEPS="intel/2018.3 openmpi/3.1.2 openmm/7.4.1"
fi
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mosdef-hub/foyer/archive/refs/tags/${VERSION}.tar.gz"
PYTHON_DEPS="lark-parser lxml gmso networkx>=2.5 parmed>=3.4.3 ele requests"
PATCHES="foyer.patch"
