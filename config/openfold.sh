PYTHON_DEPS='torch~=1.13.0'
MODULE_BUILD_DEPS='arch/avx2 cuda/11.4'
MODULE_RUNTIME_DEPS='gcc openmpi openmm/7.7'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/aqlaboratory/openfold/archive/refs/tags/v${VERSION:?version required}.tar.gz"
