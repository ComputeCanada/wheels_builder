MODULE_BUILD_DEPS="openslide"
PRE_BUILD_COMMANDS='sed -i -e "/import sys/a import os" -e "s;.libopenslide.so.0.;os.environ.get(\"EBROOTOPENSLIDE\",\"$EBROOTOPENSLIDE\") + \"/lib/libopenslide.so.0\";g" $(find . -name "lowlevel.py")'

