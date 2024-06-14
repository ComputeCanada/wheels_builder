if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="cuda/12"
	MODULE_RUNTIME_DEPS='opencv'
else
	MODULE_RUNTIME_DEPS="cuda/11.4 opencv/4.5.5"
fi
PYTHON_IMPORT_DEPS="torch cupy numba"
