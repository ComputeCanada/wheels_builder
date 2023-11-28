MODULE_BUILD_DEPS="rust"
PYTHON_DEPS='setuptools_rust maturin'
PRE_BUILD_COMMANDS='
	export CARGO_BUILD_JOBS=4;
'
