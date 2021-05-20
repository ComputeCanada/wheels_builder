This documents how I built TF 2.5.

Author: Carl Lemaire

## Script

I have made a script (build_2.5.sh) with which I have succesfully build TF 2.5, for python versions 3.6, 3.7 and 3.8.

This script has some depenencies:

* Get bazelisk (https://github.com/bazelbuild/bazelisk). Just download the release and rename (or symlink) it as `bazel`. Then, set `BAZEL_BIN_PATH` to the path that contains the `bazel` executable.
* Checkout the tensorflow source (at the right version, see TF docs), then set `TF_SOURCE_PATH`.
* Make sure you have the patched version of `patchelf`. I have made it available on the build node, and the path is hardcoded in the script.
* You will have to answer the questions from the `configure` step. Please refer to the "configure" section below.

It's useful to refer to the docs: https://www.tensorflow.org/install/source

## Steps 

The following describes the manual steps.

You will have to repeat those steps to make a wheel for each python version. Load the corresponding python module.

### Load the Nvidia dependencies 

 module load gcc/9.3 cuda/11.0 cudnn/8 nccl/2.7

* The binaries are found in $EBROOTCUDA, $EBROOTCUDNN, etc. Use these paths in the steps below.
* Used cuda 11.0 since it was the most recent compatible with our most recent cudnn (8.0.3). Update: cudnn 8.2 has been installed, so we could use cuda 11.1 (need to use 11. for compat with cedar).
* Eventually, we might want to install a more recent tensorrt, and build with it.

### Follow instructions from TF docs 

https://www.tensorflow.org/install/source

Don't forget to create and activate a virtualenv with the required deps (e.g. numpy).

### Configure 

The answers can be found in the section "config file" below.

For most questions, use the default (press enter). However:

* For questions about python, make sure you point to your virtualenv (not cvmfs python installation)
* Build with CUDA (not by default), and refer to the following for the answers of CUDA-related questions.

I did not build with TensorRT support since we don't have a version compatible with CUDA 11.

The configure script will ask for details about the CUDA installation. I paste the following lines to answer the 5 questions:
 11
 8
 2.7
 /cvmfs/soft.computecanada.ca/easybuild/software/2020/Core/cudacore/11.0.2,/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/cudnn/8.0.3,/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/nccl/2.7.8
 3.5,3.7,6.0,7.0,7.5

Note: the last line is for compute capabilities. 3.x are for Hélios.

There is one variable that the configure script does not allow to set, and has to be set manually (note that my script can set it):

The configure step produces a config file: <code>.tf_configure.bazelrc</code>

Add:
 build --action_env GCC_HOST_COMPILER_PREFIX="/cvmfs/soft.computecanada.ca/gentoo/2020/usr/bin"

### Patching the wheel 

NOTE: You will need to use a patched version of patchelf (built by Bart Oldeman). I have made it available here <code>/home/lemc2220/bin/patchelf</code>. It is used by <code>setrpaths.sh</code>. To use the patched version, do:

 export PATH=/home/lemc2220/bin:$PATH

Then you can patch the wheel:

 setrpaths.sh --path WHEEL.whl --add_path LIB_PATHS --any_interpreter --add_origin

Where LIB_PATHS are the CUDA_PATHS present in the configure file, but with colons, and with an added lib or lib64 at the end. Example:

 /cvmfs/soft.computecanada.ca/easybuild/software/2020/Core/cudacore/11.0.2/lib64:/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/cudnn/8.0.3/lib64:/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/nccl/2.7.8/lib64

Complete command example:

 setrpaths.sh --path tensorflow-2.5.0-cp38-cp38-linux_x86_64.whl --add_path /cvmfs/soft.computecanada.ca/easybuild/software/2020/Core/cudacore/11.0.2/lib64:/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/cudnn/8.0.3/lib64:/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/nccl/2.7.8/lib64 --any_interpreter --add_origin

## Tips

* You might want to run <code>bazel clean</code> before each build
* If when building the wheel, you get "error: invalid command 'bdist_wheel'", that means something is wrong with your .tf_configure.bazelrc. Do ./configure again, making sure to point to your virtualenv. Also make sure that the wheel named "wheel" is installed in the venv.
* I had to use a specific version of numpy, even if not mentionned in TF's install guide. I had to use numpy==1.19.2

## Config file

<code>.tf_configure.bazelrc</code>

Notes: You will have to replace the virtualenv paths.

 build --action_env PYTHON_BIN_PATH="/home/lemc2220/source/venv-tfbuild/bin/python3"
 build --action_env PYTHON_LIB_PATH="/home/lemc2220/source/venv-tfbuild/lib/python3.8/site-packages"
 build --python_path="/home/lemc2220/source/venv-tfbuild/bin/python3"
 build --action_env TF_CUDA_VERSION="11"
 build --action_env TF_CUDNN_VERSION="8"
 build --action_env TF_NCCL_VERSION="2.7"
 build --action_env TF_CUDA_PATHS="/cvmfs/soft.computecanada.ca/easybuild/software/2020/Core/cudacore/11.0.2,/cvmfs/soft.computecanada.ca/easybuild/software/2020/CUDA/cuda11.0/cudnn/8.0.3,/cvmfs/soft.computecanada.ca/easybuild/ software/2020/CUDA/cuda11.0/nccl/2.7.8"
 build --action_env CUDA_TOOLKIT_PATH="/cvmfs/soft.computecanada.ca/easybuild/software/2020/Core/cudacore/11.0.2"
 build --action_env TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7,6.0,7.0,7.5"
 build --action_env GCC_HOST_COMPILER_PREFIX="/cvmfs/soft.computecanada.ca/gentoo/2020/usr/bin"
 build --action_env GCC_HOST_COMPILER_PATH="/cvmfs/soft.computecanada.ca/easybuild/software/2020/Core/gcccore/9.3.0/bin/gcc"
 build --config=cuda
 build:opt --copt=-Wno-sign-compare
 build:opt --host_copt=-Wno-sign-compare
 test --flaky_test_attempts=3
 test --test_size_filters=small,medium
 test --test_env=LD_LIBRARY_PATH
 test:v1 --test_tag_filters=-benchmark-test,-no_oss,-no_gpu,-oss_serial
 test:v1 --build_tag_filters=-benchmark-test,-no_oss,-no_gpu
 test:v2 --test_tag_filters=-benchmark-test,-no_oss,-no_gpu,-oss_serial,-v1only
 test:v2 --build_tag_filters=-benchmark-test,-no_oss,-no_gpu,-v1only
