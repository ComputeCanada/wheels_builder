# Phew, that was fun. A monstreous design...

# Exclude Open3d-ML as it requires GUI for now.
# Open3D-ML can be installed separately if needed, once patched.

# Must use Git as no setup.py in root directory.
PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PYTHON_IMPORT_NAME=$PACKAGE
PACKAGE_FOLDER_NAME=$PACKAGE
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/isl-org/Open3D"
PACKAGE_DOWNLOAD_CMD="git clone --depth 1 --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch v${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"

if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	MODULE_BUILD_DEPS="eigen clang cuda/12 protobuf flexiblas abseil"
else
	MODULE_BUILD_DEPS="vtk/9 eigen clang cuda/11.7 protobuf flexiblas"
fi

PYTHON_DEPS="torch${TORCH_VERSION:+==$TORCH_VERSION} yapf==0.30.0"
# Build for CPU then GPU, order is important.
	# export PYTHONPATH=$VIRTUAL_ENV/lib/python3.*/site-packages:$PYTHONPATH;
PRE_BUILD_COMMANDS="
	export TORCH_CUDA_ARCH_LIST='7.0;7.5;8.0;8.6;9.0';

	sed -i -e "/obsoletes=/d" python/setup.py;

	cmake -B _build -S . -DDEVELOPER_BUILD=OFF -DBUILD_EXAMPLES=OFF -DUSE_SYSTEM_VTK=OFF -DUSE_SYSTEM_EIGEN3=ON \
	                     -DBUILD_ISPC_MODULE=OFF -DCMAKE_VERBOSE_MAKEFILE=ON -DBUILD_GUI=OFF \
	                     -DCMAKE_CXX_FLAGS=-Wno-error=deprecated-declarations \
	                     -DBUILD_CUDA_MODULE=OFF \
	                     -DBUILD_PYTORCH_OPS=ON -DUSE_BLAS=ON -DUSE_SYSTEM_BLAS=ON -DBLA_VENDOR=FlexiBLAS;
	cmake --build _build --config Release --parallel;

	cmake -B _build -S . -DDEVELOPER_BUILD=OFF -DBUILD_EXAMPLES=OFF -DUSE_SYSTEM_VTK=OFF -DUSE_SYSTEM_EIGEN3=ON \
	                     -DBUILD_ISPC_MODULE=OFF -DCMAKE_VERBOSE_MAKEFILE=ON -DBUILD_GUI=OFF \
	                     -DCMAKE_CXX_FLAGS=-Wno-error=deprecated-declarations \
	                     -DBUILD_CUDA_MODULE=ON -DCMAKE_CUDA_ARCHITECTURES=${TORCH_CUDA_ARCH_LIST//.} \
	                     -DBUILD_PYTORCH_OPS=ON -DUSE_BLAS=ON -DUSE_SYSTEM_BLAS=ON -DBLA_VENDOR=FlexiBLAS;
	cmake --build _build --config Release --parallel;

	cmake --build _build --config Release -- python-package;
	cd _build/lib/python_package;
"
PATCHES="
	open3d-0.19.0-fix_stdgpu.patch
	open3d-0.19.0-fix_wayland.patch
"
POST_BUILD_COMMANDS='wheel tags --remove --platform-tag=linux_x86_64 $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'
