MODULE_BUILD_DEPS="gcc/7.3.0 cmake/3.16.3 cuda/10.1 opencv/4.2.0 protobuf/3.11.1 boost/1.68.0"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/NVIDIA/DALI"
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v$VERSION $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf ${PACKAGE}-${VERSION}.tar.gz $PACKAGE_FOLDER_NAME"
# A special version and configuration of FFMPEG is required.
PRE_BUILD_COMMANDS=$(cat <<-END
	wget https://developer.download.nvidia.com/compute/redist/nvidia-dali/ffmpeg-4.2.1.tar.bz2 &&
	tar -xf ffmpeg-4.2.1.tar.bz2 &&
	cd ffmpeg-4.2.1 &&
	./configure --prefix=. --disable-all --disable-autodetect --disable-iconv --disable-shared --enable-pic --enable-avformat --enable-avcodec --enable-avfilter --enable-protocol=file --enable-demuxer=mov,matroska,avi --enable-bsf=h264_mp4toannexb,hevc_mp4toannexb,mpeg4_unpack_bframes &&
	make -j &&
	make install &&
	cd .. &&
	mkdir build &&
	cd build &&
	cmake -DCMAKE_SKIP_RPATH=ON -DBUILD_NVJPEG=ON -DCMAKE_PREFIX_PATH=$EBROOTPROTOBUF -DProtobuf_INCLUDE_DIRS=$EBROOTPROTOBUF/include -DProtobuf_LIBRARIES=$EBROOTPROTOBUF/lib -DProtobuf_LIBRARY=$EBROOTPROTOBUF/lib/libprotobuf.so -DBUILD_TEST=OFF -DBUILD_BENCHMARK=OFF -DFFMPEG_ROOT_DIR=\$(realpath ../ffmpeg-4.2.1) -Davformat_INCLUDE_DIRS=\$(realpath ../ffmpeg-4.2.1/include) .. &&
	make -j &&
	cd dali/python
END
) # This must stay on a separate line!
# The wheel is not universal
POST_BUILD_COMMANDS="PYVER=\${EBVERSIONPYTHON::-2}; mv \$WHEEL_NAME \${WHEEL_NAME/py3-none-any/cp\${PYVER//.}-cp\${PYVER//.}m-linux_x86_64} && WHEEL_NAME=\$(ls *.whl)"
RPATH_TO_ADD="\$ORIGIN"  # Force origin. Equivalent to use `--add_origin`.
