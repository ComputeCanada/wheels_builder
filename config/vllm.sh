# Use GH sources, https://github.com/vllm-project/vllm/issues/1922
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/vllm-project/vllm/archive/refs/tags/v${VERSION:?version required}.tar.gz"
MODULE_RUNTIME_DEPS='arrow'
MODULE_BUILD_DEPS='cuda protobuf abseil nccl'
PYTHON_DEPS='torch==2.3.1'
# nvcc uses os.cpu_count() hardcoded threads which returns 16
PRE_BUILD_COMMANDS='
	export TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;9.0";
	export MAX_JOBS=${SLURM_CPUS_PER_TASK:-1};
	sed -i -e "0,/MAIN_CUDA_VERSION/{s/MAIN_CUDA_VERSION.*/MAIN_CUDA_VERSION=\"$EBVERSIONCUDA\"/}" setup.py;
	sed -i -e "s/cupy-cuda12x/cupy/" -e "/vllm-nccl-.*/d" -e "/^cmake/d" -e "$ a triton" requirements*.txt;
	rm -f requirements-build.txt;
'
PYTHON_TESTS='from vllm._C import *'
