# Dummy PyArrow

Dummy `sdist` to inform users to load the module.

`PyArrow` is available from the `Arrow` module, please see https://docs.alliancecan.ca/wiki/Arrow

It is important to **ALWAYS** load the Arrow module *before* activating a virtual environment.

```bash
module load gcc python/3.11 arrow/17.0.0
python -c 'import pyarrow'
virtualenv --no-download --clear ~/ENV && source ~/ENV/bin/activate
pip install --no-index ...
```

# Dev
Generate `sdist` in `dist` directory.
```bash
python setup.py sdist; # default higher version
for v in $(module --terse spider arrow); do # define specific versions
	PYARROW_DUMMY_VERSION=${v##arrow/} python setup.py sdist; 
done
```
