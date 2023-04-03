MODULE_BUILD_DEPS='rapidjson'
PRE_BUILD_COMMANDS='python setup.py build_ext --rj-include-dir=$EBROOTRAPIDJSON/include'
