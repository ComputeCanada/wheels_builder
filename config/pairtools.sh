MODULE_BUILD_DEPS='samtools htslib'
PYTHON_DEPS="numpy>=1.10 click>=6.6 scipy>=1.7.0 pandas>=1.3.4 pysam>=0.15.0 pyyaml bioframe>=0.3.3"
PATCHES='pairtools-1.0.1-fix_pysam_libs.patch'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/open2c/pairtools/archive/refs/tags/v${VERSION:?version required}.tar.gz"
