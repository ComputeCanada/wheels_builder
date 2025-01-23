# Dummy MPI4py

Dummy `sdist` to inform users to load the module.

`mpi4py` is available from the `mpi4py` module, please see https://docs.alliancecan.ca/wiki/MPI4py

It is important to **ALWAYS** load the `mpi4py` module *before* activating a virtual environment.

```bash
module load gcc python/3.11 mpi4py/4.0.0
python -c 'import mpi4py'
virtualenv --no-download --clear ~/ENV && source ~/ENV/bin/activate
pip install --no-index ...
```

# Dev
Generate `sdist` in `dist` directory.
```bash
python setup.py sdist; # default higher version
python setup.py bdist_wheel;
for v in $(module --terse spider mpi4py); do # define specific versions
	DUMMY_VERSION=${v##mpi4py/} python setup.py bdist_wheel; 
done
```
