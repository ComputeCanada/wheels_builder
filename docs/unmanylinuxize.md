# `unmanylinuxize.sh`

This script allow one to download a `manylinux` wheel and patch it.

!!! tip "optimization"
    Prefer to build with `build_wheels.sh` (and source) when possible.

A number of (difficult to build) Python packages are distributed as binary wheels
that are compatible with many common Linux distributions and therefore tagged 
with `manylinux` in the filename. These are -- out of the box -- incompatible
with the software stack, because most of our libraries live in different locations.

However this script can download and patch `manylinux` wheels (basically by 
treating them with the `setrpaths.sh` script), thereby trying to make them 
compatible with the software stack.

## Usage
```
Usage: unmanylinuxize.sh 
  --package <package name> 
  [--version <version>]
  [--python <comma separated list of python versions>]
  [--add_path <add rpath>]
  [--add_origin <add origin to rpath>]
  [--find_links https://index.url | --url https://direct.url.to.wheel.whl ]
```

`--find-links` set `PIP_FIND_LINKS` and can be useful to search an alternative index then PyPI.

`--url` allows one to directly download a specific wheel file with `wget`

## Examples
## Specific version
```bash
bash unmanylinuxize.sh --package sktime --version 0.21.1
```

## Specific python version
```bash
bash unmanylinuxize.sh --package sktime --version 0.21.1 --python 3.11
```

## Add rpath
```bash
$ module load cuda/12 cudnn/9  # important to load prior
$ bash unmanylinuxize.sh --package open3d --add_path $EBROOTCUDACORE/lib/:$EBROOTCUDNN/lib
```

## With config file
Some package may benefit from having a configuration, ie jaxlib
```bash
$ bash unmanylinuxize.sh --package ray 
INFO: Sourced configuration /home/coulombc/wheels_builder/config/ray.sh
...
```

## With extra index
### find-links
If a package is available on an extra index, such as nvidia index
```bash
$ bash unmanylinuxize.sh --package <name> --find-links https://pypi.nvidia.com
```
### Direct URL
If a package is available from a release on Github, it can be downloaded with:
```bash
$ bash unmanylinuxize.sh --package <name> --url <url>/<name>.whl
```
