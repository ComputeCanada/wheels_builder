libraries = [ 'flexiblas', 'scalapack', 'fftw3', 'xc' ]
extra_compile_args += ['-fopenmp']
extra_link_args += ['-fopenmp']
scalapack = True
fftw = True

