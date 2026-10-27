# wheels_builder

Scripts to automate building and managing Python wheels for the Digital Research Alliance of Canada (DRAC) wheelhouse.

## Workflow Overview

1. **Build or Adapt**: Compile wheels from source with [`build_wheel.sh`](docs/build_wheels.md) (or batch build with [`parbuild_wheel.sh`](docs/parbuild_wheel.md)). For binary-only distributions, adapt pre-built wheels with [`unmanylinuxize.sh`](docs/unmanylinuxize.md).
2. **Inspect Compatibility**: Use [`wheel_architecture.sh`](docs/wheel_architecture.md) to verify library linkage, glibc compatibility, and detect target architecture.
3. **Deploy**: Copy wheels into the appropriate wheelhouse directory and adjust permissions with [`cp_wheels.sh`](docs/cp_wheels.md).

---

## Documentation

- [`build_wheel.sh`](docs/build_wheels.md)
  : Build wheel(s) for a Python package from source across standard Python versions.
    
- [`wheel_architecture.sh`](docs/wheel_architecture.md)
  : Analyzes wheel contents, checks glibc and library dependencies, and predicts the destination wheelhouse directory.
   
- [`cp_wheels.sh`](docs/cp_wheels.md)
  : Copies built wheels to their target location in the CVMFS wheelhouse with proper permissions.
 
- [`parbuild_wheel.sh`](docs/parbuild_wheel.md)
  : Builds multiple packages or versions in parallel across available CPU cores.
 
- [`unmanylinuxize.sh`](docs/unmanylinuxize.md)
  : Downloads pre-built `manylinux` wheels and patches RPATHs and metadata for the DRAC stack.
 
- [`config/<package>.sh`](docs/config.md)
  : Configuration recipes providing custom hooks and build variables for specific packages.
 
- [`manipulate_wheels.py`](docs/manipulate_wheels.md)
  : Inspects and modifies wheel metadata, requirements, and local tags without rebuilding.

---

## Quickstart

### Build a wheel for a specific version
```bash
$ bash build_wheel.sh --package <name> --version <version> --verbose 3
```

### Inspect wheel placement
```bash
$ bash wheel_architecture.sh <wheel_file>.whl
```

### Deploy to wheelhouse
```bash
$ bash cp_wheels.sh --remove --wheel <wheel_file>.whl
```
