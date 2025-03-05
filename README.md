# wheels_builder

Scripts to automate building Python wheels for DRAC's wheelhouse.

**Documentation:**
  * [`build_wheel.sh`](docs/build_wheels.md)
  * [`wheel_architecture.sh`](docs/wheel_architecture.md)
  * [`cp_wheels.sh`](docs/cp_wheels.md)
  * [`parbuild_wheel.sh`](docs/parbuild_wheel.md)
  * [`unmanylinuxize.sh`](docs/unmanylinuxize.md)
  * [`config/<package>.sh`](docs/config.md)
  * [`manipulate_wheels.py`](docs/manipulate_wheels.md)


## TLDR

1. Build a wheel for a specific version:
```bash
bash build_wheels.sh --package <name> --version <version> --verbose 3
```
