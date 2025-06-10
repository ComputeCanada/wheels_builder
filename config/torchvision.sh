PYTHON_DEPS="pillow-simd torch${TORCH_VERSION:+==$TORCH_VERSION}"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="gcc cuda/12.6 cmake"
else
	MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.7 cmake"
fi
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pytorch/vision.git@v${VERSION:?version required}"
PRE_BUILD_COMMANDS="
	export BUILD_VERSION=$VERSION;
	export TORCH_CUDA_ARCH_LIST='7.0;8.0;9.0';
	export FORCE_CUDA=1;
	export MAX_JOBS=4;
	export PYTORCH_VERSION=\$(python -c 'import torch; print(torch.__version__)');
	export TORCHVISION_INCLUDE=$EBROOTGENTOO/include;
	export TORCHVISION_LIBRARY=$EBROOTGENTOO/lib64;
"
