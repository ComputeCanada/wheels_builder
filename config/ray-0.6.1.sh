PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/ray-project/ray/archive/ray-$VERSION.tar.gz"
MODULE_BUILD_DEPS="gcc/7.3.0 bazel/0.19.2 qt/5.10.1"
PYTHON_DEPS="numpy~=$NUMPY_DEFAULT_VERSIONscipy cython"
PACKAGE_FOLDER_NAME="ray-ray-*/python"
PRE_BUILD_COMMANDS="pwd; "
PRE_BUILD_COMMANDS="$PRE_BUILD_COMMANDS sed -i -e 's/-DPARQUET_BUILD_TESTS=off/-DPARQUET_BUILD_TESTS=off -DCMAKE_SKIP_RPATH=ON -DCMAKE_SKIP_INSTALL_RPATH=ON/g' ../thirdparty/scripts/build_parquet.sh "
PRE_BUILD_COMMANDS="$PRE_BUILD_COMMANDS && sed -i -e 's/-DARROW_WITH_ZSTD=off/-DARROW_WITH_ZSTD=off  -DCMAKE_SKIP_RPATH=ON -DCMAKE_SKIP_INSTALL_RPATH=ON/g' -e 's/927bd34aaad875e82beca2584d5d777839fa8bb0/18181fe3022d5142511f507fa3047796c627d88b/g' ../thirdparty/scripts/build_arrow.sh"
POST_BUILD_COMMANDS="setrpaths.sh --path $WHEEL_NAME --add_origin --any_interpreter "

