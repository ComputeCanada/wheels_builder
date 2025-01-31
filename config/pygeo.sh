# MACH-AERO pygeo
# https://mdolab-pygeo.readthedocs-hosted.com/en/latest/index.html
MODULE_RUNTIME_DEPS='openmpi mpi4py'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mdolab/pygeo/archive/refs/tags/v${VERSION:?version required}.tar.gz"
# PRE_BUILD_COMMANDS='
# 	cp config/defaults/config.LINUX_GFORTRAN.mk config/config.mk;
# 	make -j;
# '
# # Fix tags
# POST_BUILD_COMMANDS='wheel tags --remove --abi-tag=none --python-tag=py3 --platform-tag=linux_x86_64 $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
