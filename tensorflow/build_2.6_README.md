# Building TF 2.6

For this version of TF, `build_2.5.sh` still works. Its documentation (`build_2.5_README.md`) largely applies still.

Before building, I ran: `git checkout r2.6`.

I decided to compile with the latest CUDA and cuDNN in CVMFS (CUDA 11.2 and cuDNN 8.2). I slightly changed the script for this:

* I changed the `module load` line to update the versions. I removed NCCL since our module refuses to load with cuda/11.2 (even if they are compatible). Anyways, by default, TF downloads NCCL from github and packages it.
* I updated the `lib_paths` variable just after, to remove the NCCL path.

Then, I updated the build config. This can be done by running `DO_CONFIGURE=1 build_2.5.sh`. Here is how I answer the prompts:

* When asked for the python installation, choose the environment variable named `env-build`, which is created by the script.
* CUDA version: `11.2` (Just `11` will not work. `11.2.2` won't work, for a different reason.)
* cuDNN version: `8.2`
* NCCL: press enter for the default config.
* When asked for CUDA paths, provide the following string, with the env variables **replaced by their value (path)**: `$EBROOTCUDA,$EBROOTCUDNN`.
* CUDA compute capabilities: `3.5,3.7,6.0,7.0,7.5`. (This covers all GPUs in Compute Canada.)
* For the other prompts press enter to keep the default value.

