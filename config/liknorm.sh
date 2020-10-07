if [[ -n $EBROOTGENTOO ]]; then
    # liknorm is at the Core level in the StdEnv/2020 stack
    MODULE_BUILD_DEPS="gcc/9.3.0 liknorm"
else
    MODULE_BUILD_DEPS="gcc/7.3.0 liknorm"
fi
