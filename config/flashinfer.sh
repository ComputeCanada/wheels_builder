# Now a py3 package that JIT compile, see flashinfer-jit-cache for JIT optimizations of kernels
MODULE_RUNTIME_DEPS='cuda/12.9'
PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION}"
