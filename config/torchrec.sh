PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/pytorch/torchrec/archive/refs/tags/v${VERSION:?version required}.tar.gz"
# Based on authors comment, they copied a requirements file from another libraries and requirements are wrong.
# Strip them and use the runtime requirements from HEAD instead
PRE_BUILD_COMMANDS='
	wget https://raw.githubusercontent.com/pytorch/torchrec/main/install-requirements.txt -O requirements.txt;
	sed -i -e "s/-nightly//" requirements.txt;
	sed -i -e "s/1.1.0a0/1.1.0/" version.txt;
'
MODULE_RUNTIME_DEPS='arch/avx2'
