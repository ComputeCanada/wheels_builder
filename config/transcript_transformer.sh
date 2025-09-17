MODULE_RUNTIME_DEPS='arrow'
PRE_BUILD_COMMANDS='
   sed -i "s/polars[[:space:]]*==[[:space:]]*1\.28/polars ~= 1.28.0/" pyproject.toml;
'
POST_BUILD_COMMANDS='
    $SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req torch -w $WHEEL_NAME
'

