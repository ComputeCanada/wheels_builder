PACKAGE_DOWNLOAD_NAME="$PACKAGE-$VERSION.tar.gz"
PYTHON_IMPORT_NAME=$PACKAGE
PACKAGE_FOLDER_NAME=$PACKAGE
PACKAGE_DOWNLOAD_METHOD="Git"
PATCHES="alphafold.patch" # Bundles scripts and run_alphafold.py
# Use repo instead of release archive so we can prepare the wheel.
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/deepmind/alphafold.git"
PACKAGE_DOWNLOAD_CMD="git clone --recursive $PACKAGE_DOWNLOAD_ARGUMENT --branch $VERSION $PACKAGE_FOLDER_NAME"
POST_DOWNLOAD_COMMANDS="tar -zcf $PACKAGE_DOWNLOAD_NAME $PACKAGE_FOLDER_NAME"
# As Alphafold does not know how to distribute a software, we will use soft requirements from
# setup.py. https://github.com/deepmind/alphafold/issues/511
PRE_BUILD_COMMANDS=$(cat <<-END
	sed -i -e 's/version=.*/version="$VERSION",/' setup.py;
	sed -i -e 's/tensorflow-cpu/tensorflow/' requirements.txt setup.py;
	sed -i -e 's/pandas==.*/pandas~=1.1.0/' -e 's/scipy==.*/scipy~=1.5.0/' requirements.txt setup.py;
	sed -i -e 's/aria2c/wget/g' -e 's/--dir=/-P /g' -e 's/--preserve-permissions//g' scripts/*.sh;
	wget https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt -P alphafold/common/;
END
) # This must stay on a separate line!
# Set wheel requirements according to requirements.txt for reproducibility. Though Alphafold has no strict requirements regardins TF.
UPDATE_REQUIREMENTS='$(tr "\n" " " < requirements.txt)'
MODULE_RUNTIME_DEPS="gcc openmpi cuda/11.4 openmm-alphafold/7.5.1"
