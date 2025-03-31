# wheels_builder

Scripts to automate building Python wheels for DRAC's wheelhouse.

**Documentation:**

  [`build_wheels.sh`](./build_wheels.md) <br />
  : Build wheel(s) for a Python package.
    
  [`wheel_architecture.sh`](./wheel_architecture.md)<br />
  : Analyzes the content of the wheel and tries to predict into which sub-directory of our wheelhouse the wheel needs to be placed.
   
  [`cp_wheels.sh`](./cp_wheels.md)<br />
  : Copy wheels in the current directory to the wheelhouse.
 
  [`parbuild_wheel.sh`](./parbuild_wheel.md)<br />
  : Build multiple versions and/or multiple wheels in parallel.
 
  [`unmanylinuxize.sh`](./unmanylinuxize.md)<br />
  : Download a `manylinux` wheel and patch it.
 
  [`config/<package>.sh`](./config.md)<br />
  : Configuration file to provide customization or specific steps/actions needed to build a wheel.
 
  [`manipulate_wheels.py`](./manipulate_wheels.md)<br />
  : Manipulate a wheel, mainly to update its metadata and requirements.


## TLDR

1. Build a wheel for a specific version:
```bash
bash build_wheels.sh --package <name> --version <version> --verbose 3
```
