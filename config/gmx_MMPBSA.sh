MODULE_BUILD_DEPS="gcc/9.3.0 openmpi/4.0.3 ambertools/20 gromacs/2020.4 qt/5.12.8"
PRE_BUILD_COMMANDS="source $EBROOTAMBERTOOLS/amber.sh"
TEST_COMMAND="gmx_MMPBSA -h"
