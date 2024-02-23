MODULE_BUILD_DEPS='rust'
# Build from the repository as the sdist missing some files
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/online-ml/river.git@${VERSION:?version required}"
