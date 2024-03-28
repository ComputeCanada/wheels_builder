# Use GH sources, https://github.com/vllm-project/vllm/issues/1922
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/vllm-project/vllm/archive/refs/tags/v${VERSION:?version required}.tar.gz"
MODULE_RUNTIME_DEPS='arrow'
MODULE_BUILD_DEPS='cuda'
PYTHON_DEPS='torch>=2.1.0'
# nvcc uses os.cpu_count() hardcoded threads which returns 16
PRE_BUILD_COMMANDS='
	export TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;9.0";
	export MAX_JOBS=1;
	sed -i -e "0,/MAIN_CUDA_VERSION/{s/MAIN_CUDA_VERSION.*/MAIN_CUDA_VERSION=\"$EBVERSIONCUDA\"/}" setup.py;
	sed -i -e "s/cupy-cuda12x/cupy/" requirements.txt;
'
