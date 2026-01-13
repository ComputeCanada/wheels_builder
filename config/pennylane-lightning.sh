MODULE_BUILD_DEPS="cmake flexiblas openmpi"
PYTHON_DEPS="pybind11 nanobind scipy"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/PennyLaneAI/pennylane-lightning/archive/refs/tags/v${VERSION:?version required}.tar.gz"

# MPI is not supported for this backend
PRE_BUILD_COMMANDS='
	export ENABLE_NANOBIND=1;
	export PL_BACKEND="lightning_qubit";
	export CMAKE_ARGS="-DENABLE_NATIVE=OFF -DENABLE_BLAS=OFF -DENABLE_OPENMP=ON -DENABLE_MPI=OFF -DBLA_VENDOR=FlexiBLAS -DENABLE_AVX=ON -DENABLE_AVX2=ON -DENABLE_LAPACK=ON -DENABLE_SCIPY_OPENBLAS=OFF";
	sed -i -e "/scipy-openblas32/d" -e "/nvidia-.*-cu12/d" scripts/configure_pyproject_toml.py;
	python scripts/configure_pyproject_toml.py;
'

PATCHES='
	pennylane_lightning-toggle_scipy_openblas.patch
'
