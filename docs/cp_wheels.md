# `cp_wheels.sh`

Copies all wheels in the current directory to the predicted location in the wheelhouse
after adjusting the permissions. 

## Usage
```
Usage: cp_wheels.sh [--wheel <wheel file>] [--arch generic|<rsnt_arch>]
                    [--remove] [--dry-run]

   --wheel <wheel file>       Process only this wheel (otherwise all in the $CWD)
   --arch generic|<rsnt_arch> Copy to a generic or arch-specific directory.
   --remove                   Delete the wheel after copying.
   --dry-run                  Just print the commands, but don't execute anything.
```

If `cp_wheels.sh` detects an arch-specific wheel, it will refuse to copy it
unless the `--arch` flag is used. Choice of arch should match what was used
when building the wheel (see `build_wheel.sh`). `cp_wheels.sh` considers a
wheel to be arch-specific if it links external libraries not in the Gentoo or
Nix compatibility layer, or if any existing wheels for the same package are in
arch-specific directories in our wheelhouse.

If `--wheel` argument is provided, then only the given file will be processed, else
all `computecanada` tagged files will be processed.

## Examples
### Copy all and remove
Will process only `computecanada` tagged wheels.
```bash
$ bash cp_wheels.sh --remove
```

### Copy specific wheel
Warning: will copy the given wheel
```bash
$ bash cp_wheels.sh --remove --wheel fastrlock-0.8.3+computecanada-cp313-cp313-linux_x86_64.whl
```

### Copy to specific arch
```bash
$ bash cp_wheels.sh --remove --arch x86-64-v3 --wheel <name>
```

### Copy multiple matched wheels
Useful to copy only a subset of wheels.
```bash
parallel bash cp_wheels.sh --remove --wheel ::: alphafold3-3.0.1+computecanada-cp31* numpy-*.whl
```
