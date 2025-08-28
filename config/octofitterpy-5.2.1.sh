# For Octofitter.jl to run we need:
# 1. use a version of Julia for which we have a module
# 2. update dependency to juliacall==0.9.25 which fixes a bug that is in 0.9.23
#
# 2025-08-27
# Authors:
# - Akshay Ghosh
# - Oliver Stueker
# with help from Olivier F. and Bart O.
MODULE_RUNTIME_DEPS="julia/1.10.10"
PATCH_WHEEL_COMMANDS="unzip -o \$ARCHNAME && \
  patch --verbose -p1 < \$SCRIPT_DIR/patches/octofitterpy_juliapkg.patch && \
  zip -f \$ARCHNAME  octofitterpy/juliapkg.json && \
  $SCRIPT_DIR/manipulate_wheels.py -v --inplace --force -w \$ARCHNAME -u 'juliacall==0.9.25'"

