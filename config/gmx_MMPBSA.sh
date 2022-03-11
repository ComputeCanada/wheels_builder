# updated for gmx_MMPBSA 1.5.0.3 by Oliver
MODULE_BUILD_DEPS="gcc/9.3.0 openmpi/4.0.3 ambertools/21 gromacs/2021.4 qt/5.15.2 mpi4py/3.1.2"
PRE_BUILD_COMMANDS="source $EBROOTAMBERTOOLS/amber.sh"
PYTHON_DEPS="ParmEd"
TEST_COMMAND="gmx_MMPBSA -h"
