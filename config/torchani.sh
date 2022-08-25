PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PACKAGE_FOLDER_NAME=$PACKAGE
PACKAGE_DOWNLOAD_METHOD="Git"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/aiqm/torchani"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch ${VERSION:?version required} $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"
PYTHON_DEPS="numpy==1.23 torch h5py ase"
MODULE_BUILD_DEPS="gcc/9.3.0 cuda/11.4"
PATCHES='torchani_cuaev_thc.patch'
# We built with cuaev but code is deprecated and wrongly assume it was not installed.
PRE_BUILD_COMMANDS="
	sed -i -e \"s/use_scm_version=True,/version='$VERSION',/\" setup.py;
	sed -i -e 's/has_cuaev =.*/has_cuaev = True/' torchani/aev.py;
"
BDIST_WHEEL_ARGS='--cuaev-all-sms'
UPDATE_REQUIREMENTS="'torch'"
