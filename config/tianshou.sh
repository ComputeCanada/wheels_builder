PYTHON_VERSIONS="python/3.11"
PRE_BUILD_COMMANDS="sed -i -e 's/numba\s=\s\"\^0\.57\.1\"/numba = \"\^0\.60\.0\"/' pyproject.toml"
