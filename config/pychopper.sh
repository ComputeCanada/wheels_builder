PACKAGE_DOWNLOAD_ARGUMENT=https://github.com/epi2me-labs/pychopper/archive/refs/tags/v${VERSION:?version required}.tar.gz
PRE_BUILD_COMMANDS="sed -i -e 's/tqdm==4.26.0/tqdm~=4.26/' requirements.txt;"
