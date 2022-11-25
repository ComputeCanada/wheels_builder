# current GPAW (22.8.0) requires LibXC 3.x or 4.x or 5.1+.  Using module libxc/5.1.3
# https://wiki.fysik.dtu.dk/gpaw/install.html#requirements
MODULE_BUILD_DEPS="gcc openmpi flexiblas blacs scalapack fftw libxc/5.2.3"
# Need a siteconfig.py for installation settings. Storing it within wheels_builder repo.
# That file contains a list of libraries to link as well as compiler-/linker flags.
# See also: https://wiki.fysik.dtu.dk/gpaw/install.html#customizing-installation
export GPAW_CONFIG="${CONFIGDIR}/gpaw_siteconfig.py"
# TEST_COMMAND="gpaw info "
