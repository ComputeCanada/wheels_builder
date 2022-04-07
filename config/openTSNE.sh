MODULE_BUILD_DEPS="arch/avx2 fftw"
PRE_BUILD_COMMANDS='export CONDA_BUILD="this is sane insanity to prevent native opt with -march=native"'
