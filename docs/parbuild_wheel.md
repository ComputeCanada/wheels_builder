# `parbuild_wheel.sh`

Build multiple versions and/or multiple wheels in parallel.
The script will use as many cores available as possible to run the builds.

## Usage
```bash
Usage: parbuild_wheel.sh 
  --package <comma separated list of package name>
  [--version <comma separated list of versions>]
  [--python <comma separated list of python versions>]
  [--requirements <requirements file>
```

## Examples
### All default python versions in parallel
```bash
$ bash parbuild_wheel.sh --package <name>
```

### Multiple packages
```bash
$ bash parbuild_wheel.sh --package <n1>,<n2>,<n3>,...
```

### Multiple version of a package
```bash
$ bash parbuild_wheel.sh --package <name> --version 1.0.0,1.0.1
```

### Specific python versions
```bash
$ bash parbuild_wheel.sh --package <name> --python 3.12,3.13
```

### From a requirements file
Will build `package==version` for all default python.
```bash
$ bash parbuild_wheel.sh --requirements requirements.txt
```