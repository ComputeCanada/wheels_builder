PRE_BUILD_COMMANDS='sed -i -e "s;SLURM_INC = \"\";SLURM_INC = \"/opt/software/slurm/include/include\";g" -e "s;SLURM_LIB = \"\";SLURM_LIB = \"/opt/software/slurm/lib\";g" setup.py'

