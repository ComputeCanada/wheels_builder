if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
    MODULE_BUILD_DEPS="gcc cuda/12.2 boost"
else
    MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.4 boost"
fi
PRE_BUILD_COMMANDS="sed -i '/\"mako\",/a \"numpy\"' setup.py"
