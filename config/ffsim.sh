# Does not build if not with openblas
MODULE_BUILD_DEPS='symengine/0.13 openblas'
PRE_DOWNLOAD_COMMANDS='export CARGO_BUILD_JOBS=${SLURM_CPUS_PER_TASK:-1}'
POST_BUILD_COMMANDS='setrpaths.sh --path $WHEEL --add_path $EBROOTOPENBLAS/lib'
