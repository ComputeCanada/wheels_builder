#PATCHES="HiCAssembler-1.1.1.patch"
PRE_BUILD_COMMANDS="sed -i '/package_data/d' setup.py && sed -i  's/import hicexplorer.HiCMatrix/import hicmatrix.HiCMatrix/' hicassembler/*py"
