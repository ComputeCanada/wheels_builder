MODULE_RUNTIME_DEPS='rdkit'
PRE_BUILD_COMMANDS='sed -i -e "s/"numpy=="/"numpy~="/" pyproject.toml'
