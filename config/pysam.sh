MODULE_BUILD_DEPS="htslib"
PRE_BUILD_COMMANDS="
        export HTSLIB_LIBRARY_DIR=$EBROOTHTSLIB/lib;
        export HTSLIB_INCLUDE_DIR=$EBROOTHTSLIB/include;
        export HTSLIB_MODE=external;
        LDFLAGS='-Wl,-rpath,$EBROOTHTSLIB/lib';
"
