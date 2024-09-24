PYTHON_DEPS='versioneer meson-python cython>3.0.10'
PRE_BUILD_COMMANDS="python setup.py clean --all"
# Avoid double build because `pip download` stupidity
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pandas-dev/pandas/archive/refs/tags/v${VERSION:?version required}.tar.gz"
