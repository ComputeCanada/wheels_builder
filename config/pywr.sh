PYTHON_DEPS='"setuptools>=62" "setuptools_scm[toml]>=8.0" "cython>=3"'
MODULE_BUILD_DEPS='glpk lpsolve'
PRE_BUILD_COMMANDS='
	sed -i -e "s#lpsolve/lp_lib.h#lp_lib.h#" pywr/solvers/cython_lpsolve.pyx;
	python setup.py build_ext --inplace -I $EBROOTLPSOLVE/include -I $EBROOTGLPK/include --with-glpk --with-lpsolve;
'
