MODULE_BUILD_DEPS='cmake'
# Force to use setup.py
PRE_BUILD_COMMANDS='rm pyproject.toml'
PYTHON_DEPS="scikit-build"
# It cannot brillantly find its own packaged dep...help it a little...
BDIST_WHEEL_ARGS=" -- -Dnlohmann_json_INCLUDE_DIR=\$PWD/external/nlohmann"
