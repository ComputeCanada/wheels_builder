MODULE_BUILD_DEPS='cuda/13 protobuf'
PYTHON_DEPS='metatensor-torch metatomic-torch featomic'
PRE_BUILD_COMMANDS='
    export CARGO_BUILD_JOBS=${SLURM_CPUS_PER_TASK:-1};
'

