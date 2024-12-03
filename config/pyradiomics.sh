PYTHON_DEPS='versioneer'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/AIM-Harvard/pyradiomics/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS="
	sed -i -e \"s/version\s*=\s*.*/version='$VERSION'/\" pyproject.toml
"
