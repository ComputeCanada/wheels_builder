MODULE_BUILD_DEPS="openslide"
PRE_BUILD_COMMANDS='sed -i -e "/import platform/a import os" -e "s;.libopenslide.so.0.;os.environ.get(\"EBROOTOPENSLIDE\",\"$EBROOTOPENSLIDE\") + \"/lib/libopenslide.so.0\";g" $(find . -name "lowlevel.py")'
PYTHON_IMPORT_NAME='openslide'
