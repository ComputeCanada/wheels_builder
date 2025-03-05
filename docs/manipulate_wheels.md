# `manipulate_wheels.py`

This script allow one to manipulate a wheel file, mainly to update its metadata and requirements.
For example, one can add, remove and update requirements.

## Usage
```bash
$ ./manipulate_wheels.py -h
usage: manipulate_wheels [-h] -w WHEELS [WHEELS ...] [-i] [-u UPDATE_REQ [UPDATE_REQ ...]] [-a ADD_REQ [ADD_REQ ...]] [-r REMOVE_REQ [REMOVE_REQ ...]] [--set_min_numpy SET_MIN_NUMPY] [--set_lt_numpy SET_LT_NUMPY] [--inplace] [--force] [-p] [-v] [-t TAG]

Manipulate wheel files

optional arguments:
  -h, --help            show this help message and exit
  -w WHEELS [WHEELS ...], --wheels WHEELS [WHEELS ...]
                        Specifies which wheels to patch (default: None)
  -i, --insert_local_version
                        Adds the +computecanada local version (default: False)
  -u UPDATE_REQ [UPDATE_REQ ...], --update_req UPDATE_REQ [UPDATE_REQ ...]
                        Updates requirements of the wheel. (default: None)
  -a ADD_REQ [ADD_REQ ...], --add_req ADD_REQ [ADD_REQ ...]
                        Add requirements to the wheel. (default: None)
  -r REMOVE_REQ [REMOVE_REQ ...], --remove_req REMOVE_REQ [REMOVE_REQ ...]
                        Remove requirements from the wheel. (default: None)
  --set_min_numpy SET_MIN_NUMPY
                        Sets the minimum required numpy version. (default: None)
  --set_lt_numpy SET_LT_NUMPY
                        Sets the lower than (<) required numpy version. (default: None)
  --inplace             Work in the same directory as the existing wheel instead of a temporary location (default: False)
  --force               If combined with --inplace, overwrites existing wheel if the resulting wheel has the same name (default: False)
  -p, --print_req       Prints the current requirements (default: False)
  -v, --verbose         Displays information about what it is doing (default: False)
  -t TAG, --add_tag TAG
                        Specifies a tag to add to wheels (default: None)
```

## Examples
### Print requirements
```bash
$ ./manipulate_wheels.py -p -w biopython-*.whl 
Resulting wheels will be in directory ./tmp
Requirements for wheel biopython-1.84+computecanada-cp312-cp312-linux_x86_64.whl:
==========================
numpy
==========================
```

### Add requirement
```bash
$ ./manipulate_wheels.py --inplace --force --add_req 'numpy' -w wheel-0.45.1-py3-none-any.whl 
Since --force was used, overwriting existing wheel
New wheel created wheel-0.45.1-py3-none-any.whl

$ ./manipulate_wheels.py -p -w wheel-0.45.1-py3-none-any.whl 
Resulting wheels will be in directory ./tmp
Requirements for wheel wheel-0.45.1-py3-none-any.whl:
==========================
pytest >= 6.0.0 ; extra == "test"
setuptools >= 65 ; extra == "test"
numpy
==========================
```

### Remove requirement
```bash
$ ./manipulate_wheels.py --inplace --force --remove_req 'numpy' -w wheel-0.45.1-py3-none-any.whl 
wheel-0.45.1-py3-none-any.whl: requirement numpy found. Removing it
Since --force was used, overwriting existing wheel
New wheel created wheel-0.45.1-py3-none-any.whl

$ ./manipulate_wheels.py -p -w wheel-0.45.1-py3-none-any.whl 
Resulting wheels will be in directory ./tmp
Requirements for wheel wheel-0.45.1-py3-none-any.whl:
==========================
pytest >= 6.0.0 ; extra == "test"
setuptools >= 65 ; extra == "test"
==========================
```

### Update requirement
Useful to adjust a version or relaxing a requirement, by removing its version specifier.

```bash
$ ./manipulate_wheels.py -p -w wheel-0.45.1-py3-none-any.whl 
Resulting wheels will be in directory ./tmp
Requirements for wheel wheel-0.45.1-py3-none-any.whl:
==========================
pytest >= 6.0.0 ; extra == "test"
setuptools >= 65 ; extra == "test"
==========================

$ ./manipulate_wheels.py --inplace --force --update_req 'setuptools' -w wheel-0.45.1-py3-none-any.whl 
Since --force was used, overwriting existing wheel
New wheel created wheel-0.45.1-py3-none-any.whl

$ ./manipulate_wheels.py -p -w wheel-0.45.1-py3-none-any.whl 
Resulting wheels will be in directory ./tmp
Requirements for wheel wheel-0.45.1-py3-none-any.whl:
==========================
pytest >= 6.0.0 ; extra == "test"
setuptools
==========================
```
#### Rename requirement

Rename a requirement, and update a requirement version:

**Note**: the special separator `->` in order to rename a requirement.
```bash
$ ./manipulate_wheels.py -v -w wheel-0.2.2-py3-none-any.whl -u "faiss-cpu->faiss" "tensorflow (>=2.2.2)"
Resulting wheels will be in directory ./tmp
wheel-0.2.2-py3-none-any.whl: updating requirement faiss-cpu to faiss
wheel-0.2.2-py3-none-any.whl: updating requirement tensorflow (>=2.2.0) to tensorflow (>=2.2.2)
New wheel created tmp/wheel-0.2.2-py3-none-any.whl
```

### Insert local tag (`computecanada`) :
```bash
$ ./manipulate_wheels.py --inplace -i -w wheel-0.2.2-py3-none-any.whl 
New wheel created wheel-0.2.2+computecanada-py3-none-any.whl
```

### Insert custom tag:
```bash
$ ./manipulate_wheels.py --inplace --add_tag custom -w wheel-0.45.1-py3-none-any.whl 
New wheel created wheel-0.45.1+custom-py3-none-any.whl
```