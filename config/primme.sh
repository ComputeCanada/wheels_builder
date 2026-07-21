PRE_BUILD_COMMANDS="
	sed -i -e \"s/'lapack', 'blas'/'flexiblas'/\" setup.py;
	export CFLAGS='-DPRIMME_WITH_CUDABLAS';
"
MODULE_BUILD_DEPS='flexiblas'
