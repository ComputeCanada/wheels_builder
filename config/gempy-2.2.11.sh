MODULE_RUNTIME_DEPS="vtk/9.1.0"
PRE_BUILD_COMMANDS="sed -i 's/pandas==1.3.4/pandas<1.4.0/' setup.py"
