# Pythonic bindings for FFmpeg's libraries
# https://github.com/mikeboers/PyAV

if [[ -n $EBROOTGENTOO ]]; then
    # Gentoo-based stack (StdEnv/2020)
    MODULE_BUILD_DEPS="gcc/9.3.0 ffmpeg/4.2.2"
else
    # NIX-based stack (StdEnv/2018.3)
    MODULE_BUILD_DEPS="gcc/7.3.0 ffmpeg/4.2.1"
fi
RPATH_TO_ADD='$EBROOTFFMPEG/lib'

