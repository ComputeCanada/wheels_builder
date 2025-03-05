# wheels_builder

Scripts to automate building Python wheels for DRAC's wheelhouse.

**Documentation:**
  * [`build_wheel.sh`](docs/build_wheels.md) 
  Build wheel(s) for a Python package.
    
  * [`wheel_architecture.sh`](docs/wheel_architecture.md)
  Analyzes the content of the wheel and tries to predict into which sub-directory of our wheelhouse the wheel needs to be placed.
   
  * [`cp_wheels.sh`](docs/cp_wheels.md)
  Copy wheels in the current directory to the wheelhouse.
 
  * [`parbuild_wheel.sh`](docs/parbuild_wheel.md)
  Build multiple versions and/or multiple wheels in parallel.
 
  * [`unmanylinuxize.sh`](docs/unmanylinuxize.md)
  Download a `manylinux` wheel and patch it.
 
  * [`config/<package>.sh`](docs/config.md)
  Configuration file to provide customization or specific steps/actions needed to build a wheel.
 
  * [`manipulate_wheels.py`](docs/manipulate_wheels.md)
  Manipulate a wheel, mainly to update its metadata and requirements.


## TLDR

1. Build a wheel for a specific version:
```bash
bash build_wheels.sh --package <name> --version <version> --verbose 3
```
