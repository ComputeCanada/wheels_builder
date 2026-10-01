PYTHON_DEPS='setuptools_rust maturin'
PRE_BUILD_COMMANDS='
	export CARGO_BUILD_JOBS=${SLURM_CPUS_PER_TASK:-1};
    export RUSTC_BOOTSTRAP=1;
'
PYTHON_IMPORT_NAME="_polars_runtime_32"
