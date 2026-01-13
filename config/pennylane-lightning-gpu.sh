MODULE_BUILD_DEPS="cmake cuda/12.9 cuquantum flexiblas openmpi"
MODULE_RUNTIME_DEPS='cuda/12.9 cuquantum'
PYTHON_DEPS="pybind11 nanobind scipy"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/PennyLaneAI/pennylane-lightning/archive/refs/tags/v${VERSION:?version required}.tar.gz"
PRE_BUILD_COMMANDS="
	export CUQUANTUM_SDK=\$EBROOTCUQUANTUM/lib;
	export PL_BACKEND="lightning_gpu";
	export CMAKE_ARGS='-DENABLE_MPI=ON -DENABLE_NATIVE=OFF -DENABLE_BLAS=OFF -DENABLE_OPENMP=ON -DBLA_VENDOR=FlexiBLAS -DENABLE_AVX=ON -DENABLE_AVX2=ON -DENABLE_LAPACK=ON -DENABLE_SCIPY_OPENBLAS=OFF';
	sed -i -e '/scipy-openblas32/d' -e '/nvidia-.*-cu12/d' -e '/nvidia-.*{package_suffix}/d' scripts/configure_pyproject_toml.py;
	python scripts/configure_pyproject_toml.py;
"

PYTHON_IMPORT_NAME='pennylane_lightning'
# `pennylane_lightning.lightning_gpu` requires a device to import correctly.

PATCHES='
    pennylane_lightning-toggle_scipy_openblas.patch
'
