PRE_BUILD_COMMANDS='
	export CYTHONIZE=1;
	export LIBDEFLATE=1;
	python setup.py clean --all build_ext --inplace
'
