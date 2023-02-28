PYTHON_DEPS=" scipy pandas numba ipyparallel pysam cutadapt requests h5py"
MODULE_RUNTIME_DEPS="muscle samtools bedtools vsearch bwa"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/dereneaton/ipyrad/archive/${VERSION:?version required}.tar.gz"
PACKAGE_DOWNLOAD_NAME="$VERSION.tar.gz"
