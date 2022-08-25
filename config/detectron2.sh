PYTHON_DEPS="torch torchvision"
PYTHON_DEPS_DEFAULT=""
MODULE_RUNTIME_DEPS="gcc/9.3.0 cuda/11.4 opencv"
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='6.0;7.0;7.5;8.0;8.6';
	export FORCE_CUDA=1;
	export MAX_JOBS=4;
	sed -i -e \"s/install_requires=\[/install_requires=\['torch',/\" setup.py;
"
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/facebookresearch/detectron2.git@v${VERSION:?version required}"
