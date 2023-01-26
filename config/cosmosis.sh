MODULE_BUILD_DEPS="gcc openmpi flexiblas"
PRE_BUILD_COMMANDS="
	export MPIFC=mpif90;
        export LAPACK_LINK=-lflexiblas;
"
