# Latest scipy forces numpy 1.24 and for python 3.9 this fails so force numpy 1.21
PYTHON_DEPS="scipy matplotlib numpy~=1.21.0;python_version<'3.10' packaging"
PRE_BUILD_COMMANDS='rm -v pyproject.toml; python setup.py clean --all;' # force using setup.py to pass arguments
BDIST_WHEEL_ARGS='--with-openmp'
