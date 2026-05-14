PYTHON_DEPS="pillow-simd torch${TORCH_VERSION:+==$TORCH_VERSION} setuptools~=80.0.0"
if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="gcc cuda/12.9 cmake"
else
	MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.7 cmake"
fi
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/pytorch/vision.git@v${VERSION:?version required}"
PRE_BUILD_COMMANDS="
	export BUILD_VERSION=$VERSION;
	export TORCH_CUDA_ARCH_LIST='8.0;9.0;10.0+PTX';
	export FORCE_CUDA=1;
	export MAX_JOBS=${SLURM_CPUS_PER_TASK:-1};
	export PYTORCH_VERSION=\$(python -c 'import torch; print(torch.__version__)');
	export TORCHVISION_INCLUDE=$EBROOTGENTOO/include;
	export TORCHVISION_LIBRARY=$EBROOTGENTOO/lib64;
"
