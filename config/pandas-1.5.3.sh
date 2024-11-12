PYTHON_DEPS='versioneer meson-python'
MODULE_BUILD_DEPS='cython/.0.29.36 oldest-supported-numpy/.2024a -numpy'
PRE_BUILD_COMMANDS="python setup.py clean --all"
# Avoid double build because `pip download`
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pandas-dev/pandas/archive/refs/tags/v${VERSION:?version required}.tar.gz"
