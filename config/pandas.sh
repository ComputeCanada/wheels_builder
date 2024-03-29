# Pandas does not support the oldest-supported-numpy version
if [[ ${VERSION} =~ 2.0.* ]]; then
	PYTHON_DEPS='versioneer numpy==1.21;python_version=="3.9" meson-python'
else
#elif [[ ${VERSION} =~ 2.1.* ]]; then
	PYTHON_DEPS='versioneer numpy~=1.22.4;python_version=="3.9" numpy~=1.22.4;python_version=="3.10" meson-python Cython~=3.0.5'
fi
PRE_BUILD_COMMANDS="python setup.py clean --all"
# Avoid double build because `pip download` stupidity
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pandas-dev/pandas/archive/refs/tags/v${VERSION:?version required}.tar.gz"
