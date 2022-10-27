# CPU only. GPU is another story...depends on RAPIDSAI
MODULE_BUILD_DEPS='cmake hdf5 eigen armadillo flexiblas python-build-bundle'
PRE_BUILD_COMMANDS="
	sed -i -e \"/'scipy'/a 'docopt',\" setup.py;
	sed -i -e 's/openblas lapack/flexiblas/' CMakeLists.txt;
"
