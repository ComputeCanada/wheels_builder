TORCH_VERSION=1.12.0
PYTHON_DEPS="torch==$TORCH_VERSION torchvision"
MODULE_RUNTIME_DEPS="gcc/9.3.0 cuda/11.4 opencv"
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
	export FORCE_CUDA=1;
	export MAX_JOBS=4;
	export D2_VERSION_SUFFIX='+torch${TORCH_VERSION//./}';
	sed -i -e \"s/install_requires=\[/install_requires=\['torch==$TORCH_VERSION',/\" setup.py;
"
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/facebookresearch/detectron2.git@v${VERSION:?version required}"
