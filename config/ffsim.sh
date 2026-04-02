# Does not build if not with openblas
MODULE_BUILD_DEPS='symengine openblas'
PRE_DOWNLOAD_COMMANDS='export CARGO_BUILD_JOBS=${SLURM_CPUS_PER_TASK:-1}'
POST_BUILD_COMMANDS='setrpaths --path $WHEEL_NAME --add_path $EBROOTOPENBLAS/lib'
