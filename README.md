# wheels_builder

Scripts to automate building Python wheels for DRAC's wheelhouse.

**Table of Content:**

* [Quick Start]
  * [`build_wheel.sh`](./docs/#build_wheelsh)
  * [`wheel_architecture.sh`](./docs/#wheel_architecturesh)
  * [`cp_wheels.sh`](./docs/#cp_wheelssh)
  * [`parbuild_wheel.sh`](./docs/#parbuild_wheelsh)
  * [`unmanylinuxize.sh`](./docs/#unmanylinuxizesh)
  * [`config/<package>.sh`](./docs/#configurations)
  * [`manipulate_wheels.py`](./docs/#manipulate_wheelspy)


## TLDR

1. Build a wheel for a specific version:
```bash
bash build_wheels.sh --package <name> --version <version> --verbose 3
```
