PRE_BUILD_COMMANDS='sed -i -e "s@-fno-inline@-fno-inline\x27,\x27-L${EBROOTSUITESPARSE}/lib@g" setup.py; sed -i -e "s@/usr/include/suitesparse@${EBROOTSUITESPARSE}/include@g" setup.py; sed -i -e "s@lapack@mkl@g" setup.py'
MODULE_BUILD_DEPS="suitesparse imkl"
PYTHON_DEPS="numpy"

