MODULE_BUILD_DEPS="rust"
MODULE_RUNTIME_DEPS="arrow"
PYTHON_DEPS='maturin'
PRE_BUILD_COMMANDS='export CARGO_BUILD_JOBS=$SLURM_CPUS_PER_TASK'