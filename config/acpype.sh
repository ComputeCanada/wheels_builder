# official repository: https://github.com/alanwilter/acpype
# requires AmberTools and OpenBabel to run

if [[ "$EBVERSIONGENTOO" -eq "2020" ]] ; then
    MODULE_BUILD_DEPS="flexiblas arpack-ng netcdf hdf5"
    MODULE_RUNTIME_DEPS="gcc/9.3.0 openbabel"
elif [[ "$EBVERSIONGENTOO" -eq "2023" ]] ; then
    MODULE_BUILD_DEPS="flexiblas arpack-ng netcdf hdf5"
    MODULE_RUNTIME_DEPS="gcc/12.3 openbabel"
else
    MODULE_BUILD_DEPS="flexiblas arpack-ng netcdf hdf5"
    MODULE_RUNTIME_DEPS="gcc openbabel"
fi

PRE_BUILD_COMMANDS="patchelf --replace-needed libblas.so.3 libflexiblas.so.3 --remove-needed liblapack.so.3 acpype/amber_linux/bin/sqm ; patchelf --replace-needed libblas.so.3 libflexiblas.so.3 acpype/amber_linux/lib/libsff_fortran.so ; "
RPATH_TO_ADD='$EBROOTGENTOO/lib64:$EBROOTFLEXIBLAS/lib64:$EBROOTARPACKMINNG/lib64:$EBROOTNETCDF/lib64:$EBROOTHDF5/lib64'

UPDATE_REQUIREMENTS='"openbabel-wheel->openbabel (>=3.1.1.1,<4.0.0.0)"'


TEST_COMMAND="acpype -i CCCC"

