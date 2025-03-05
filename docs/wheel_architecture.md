# `wheel_architecture.sh`

Analyzes the content of the wheel and tries to make some prediction into which sub-directory
of our wheelhouse the wheel needs to be placed.

## Usage
```
Usage: wheel_architecture.sh  <FILENAME>.whl
```

* generic generic : Generic in terms of nix/gentoo prefix as well as for architecture
* nix     generic : requires NIX but is not architecture dependent
* gentoo  generic : requires Gentoo prefix but is not architecture dependent
* nix     avx2    : requires NIX and depends on libraries located in arch/avx2
* ...
* gentoo2023 generic : requires Gentoo 2023 but is not architecture dependent. May contains `x86-64-v3` optimizations.
* x86-64-v3 avx2  : requires Gentoo 2023 and depends on libraries located in arch/avx2
* x86-64-v4 avx512  : requires Gentoo 2023 and depends on libraries located in arch/avx512

> [!NOTE]  
> While the script tries to make a good job, there are cases e.g. when a wheel
> depends on a certain library or certain version of a library that is available only 
> in one of the NIX or Gentoo layers but not the other, where it makes a wrong prediction.

Make sure to test it!

## Examples
### Pure Python wheel
```bash
$ bash wheel_architecture.sh transformers-4.49.0+computecanada-py3-none-any.whl
generic generic
```
This generic wheels contains no extension nor SOs that depend on a library.

### Arch specific
```bash
$ bash wheel_architecture.sh pyFFTW-0.13.1+computecanada-cp311-cp311-linux_x86_64.whl
...
gentoo2023 x86-64-v3
```
This wheel depends on FFTW libraries.

### Missing SO
Some package may depends on libraries that will be installed in a virtual environment. Those must be analyzed with care.
```bash
$ bash wheel_architecture.sh torchtext-0.18.0+computecanada-cp310-cp310-linux_x86_64.whl
./torchtext/_torchtext.so requires a glibc more recent than that provided by Gentoo 2020: 2.34 > 2.30
	libtorch_python.so => not found
	libc10.so => not found
	libtorch.so => not found
	libtorch_cpu.so => not found
	libtorch_python.so => not found
	libc10.so => not found
	libtorch.so => not found
	libtorch_cpu.so => not found
./torchtext/_torchtext.so is missing some libraries in Gentoo 2020
./torchtext/_torchtext.so is missing some libraries in Gentoo 2023
./torchtext/lib/libtorchtext.so requires a glibc more recent than that provided by Gentoo 2020: 2.34 > 2.30
	libc10.so => not found
	libtorch.so => not found
	libtorch_cpu.so => not found
	libc10.so => not found
	libtorch.so => not found
	libtorch_cpu.so => not found
./torchtext/lib/libtorchtext.so is missing some libraries in Gentoo 2020
./torchtext/lib/libtorchtext.so is missing some libraries in Gentoo 2023
unknown generic
```
Since it requires a glibc 2.34 but cannot find `libtorch.so`, the script cannot correctly determine which architecture. We then need to copy it with care under `gentoo2023/generic`.
