# cuda-python is now a meta pacakge (Pure Python).
if [[ -n "$VERSION" ]] && [[ $(translate_version $VERSION) -lt $(translate_version '12.8.0')  ]]; then
	MODULE_BUILD_DEPS='cuda'
	PYTHON_DEPS='pyclibrary'
	PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/NVIDIA/cuda-python/archive/refs/tags/v${VERSION:?version required}.tar.gz"
	PYTHON_IMPORT_NAME='cuda'
fi
