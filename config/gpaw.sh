# current GPAW (21.6.0) requires LibXC 3.x or 4.x.  Using module libxc/4.3.4
# https://wiki.fysik.dtu.dk/gpaw/install.html#requirements
MODULE_BUILD_DEPS="gcc openmpi blacs scalapack fftw libxc/4.3.4"
# need a siteconfig.py for installation settings. Storing it within wheels_builder repo.
export GPAW_CONFIG="${CONFIGDIR}/gpaw_siteconfig.py"
# TEST_COMMAND="gpaw info "
