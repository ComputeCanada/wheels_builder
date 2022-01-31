if [[ -n $EBROOTGENTOO ]]; then
    MODULE_RUNTIME_DEPS="packmol"
else
    MODULE_RUNTIME_DEPS="intel/2018.3 openmpi/3.1.2 packmol/18.013"
fi
PYTHON_DEPS="ele pandas oset ParmEd mdtraj"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mosdef-hub/mbuild/archive/refs/tags/${VERSION}.tar.gz"
#UPDATE_REQUIREMENTS="numpy scipy ele pandas oset ParmEd mdtraj"
PATCHES="mbuild.patch"
