MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.4 boost"
PRE_BUILD_COMMANDS="sed -i '/\"mako\",/a \"numpy\"' setup.py"
