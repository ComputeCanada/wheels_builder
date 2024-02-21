MODULE_BUILD_DEPS="openslide"
# Match `'libopenslide.so.[0-9]` to the actual library path, by inserting the path
# to the library from the environment variable `EBROOTOPENSLIDE` before the library name.
# or use the path from the current loaded module.
PRE_BUILD_COMMANDS='
    sed -i -e "/import platform/a import os" -e "s;[[:punct:]]libopenslide.so.[0-9];os.environ.get(\"EBROOTOPENSLIDE\",\"$EBROOTOPENSLIDE\") + \"/lib/\" + &;g" openslide/lowlevel.py
'
PYTHON_IMPORT_NAME='openslide'
