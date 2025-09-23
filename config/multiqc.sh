MODULE_RUNTIME_DEPS='arrow'
PRE_BUILD_COMMANDS='sed -i -e "s/polars-lts-cpu/polars/" pyproject.toml'
