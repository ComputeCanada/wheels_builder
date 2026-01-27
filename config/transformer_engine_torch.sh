# pip download strip build_tools directory... so use git
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/NVIDIA/TransformerEngine.git@v${VERSION:?version required}"

if [[ -z "$TORCH_VERSION" ]]; then
    MODULE_RUNTIME_DEPS='cuda/12.9 cudnn'

elif [[ $(translate_version "$TORCH_VERSION") -lt $(translate_version '2.7.0') ]]; then
    MODULE_RUNTIME_DEPS='cuda/12.2 cudnn'

elif [[ $(translate_version "$TORCH_VERSION") -ge $(translate_version '2.7.0') \
     && $(translate_version "$TORCH_VERSION") -lt $(translate_version '2.10.0') ]]; then
    MODULE_RUNTIME_DEPS='cuda/12.6 cudnn'
fi

PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
PRE_BUILD_COMMANDS='
	cd transformer_engine/pytorch;
	export MAX_JOBS=${SLURM_CPUS_PER_TASK:-1};
	export NVTE_BUILD_THREADS_PER_JOB=1;
	export NVTE_RELEASE_BUILD=1;
    export NVTE_CUDA_ARCHS="70;80;90";
    python setup.py build_ext;
'
PRE_TEST_COMMANDS='
    export CUDNN_HOME=$EBROOTCUDNN;
'
PYTHON_IMPORT_NAME='transformer_engine'

POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req numpy -w $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
