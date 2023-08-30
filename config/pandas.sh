# Pandas does not support the oldest-supported-numpy version
PYTHON_DEPS='versioneer numpy==1.21;python_version=="3.9" meson-python'
PRE_BUILD_COMMANDS="python setup.py clean --all"

