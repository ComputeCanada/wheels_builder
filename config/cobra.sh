if [[ -n $EBROOTGENTOO ]]; then
    # Gentoo-based stack (StdEnv/2020)
    MODULE_BUILD_DEPS="glpk/5.0"
else
    # NIX-based stack (StdEnv/2018.3)
    MODULE_BUILD_DEPS="gcc/7.3.0 glpk/4.65"
fi



