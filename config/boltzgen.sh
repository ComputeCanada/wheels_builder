MODULE_RUNTIME_DEPS='rdkit'
PRE_BUILD_COMMANDS='
    sed -i -e "s/numpy==2.0.2"/numpy>=2.0.2/" pyproject.toml
'
