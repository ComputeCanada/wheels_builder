# Building TF 2.6

For this version of TF, `build_2.5.sh` still works. Its documentation (`build_2.5_README.md`) largely applies still.

The most important difference is to make sure to checkout the right version before running the script: `git checkout r2.6`. For the rest, the script should work as-is. Note that this will use these modules: `cuda/11.1 cudnn/8.2 nccl/2.8.4`.

I decided to compile with the latest CUDA in CVMFS (CUDA 11.2 at this time). I had to slightly change the script and reconfigure the build. First, the script:

* I changed the `module load` line to update the versions. I removed NCCL since our module refuses to load with cuda/11.2 (even if they are compatible). Anyways, by default, TF downloads NCCL from github and packages it.
* I updated the `lib_paths` variable just after, to remove the NCCL path.

Then, I updated the build config. This can be done by running `DO_CONFIGURE=1 build_2.5.sh`. Here is how I answered the prompts:

* When asked for the python installation, choose the environment variable named `env-build`, which is created by the script.
* CUDA version: `11.2` (Just `11` will not work. `11.2.2` won't work, for a different reason.)
* cuDNN version: `8.2`
* NCCL: press enter for the default config.
* When asked for CUDA paths, provide the following string, with the env variables **replaced by their value (path)**: `$EBROOTCUDA,$EBROOTCUDNN`.
* CUDA compute capabilities: `3.5,3.7,6.0,7.0,7.5`. (This covers all GPUs in Compute Canada.)
* For the other prompts press enter to keep the default value.

