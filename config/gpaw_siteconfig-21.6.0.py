libraries = [ 'openblas', 'scalapack', 'fftw3', 'xcf90', 'xc' ]
extra_compile_args += ['-fopenmp']
extra_link_args += ['-fopenmp']
scalapack = True
fftw = True

