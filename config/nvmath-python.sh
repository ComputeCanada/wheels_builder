if [[ -n "$VERSION" ]] && [[ 10#$(translate_version $VERSION) -lt 10#$(translate_version '0.8.0')  ]]; then
	MODULE_BUILD_DEPS='cuda/12.9'
	PYTHON_DEPS='cuda-bindings==12.9.*'
else
	MODULE_BUILD_DEPS='cuda/13.2'
	PYTHON_DEPS='cuda-bindings==13.2.*'
fi
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/NVIDIA/nvmath-python@v${VERSION:?version required}"
