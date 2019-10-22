# torch_cpu, six and numpy are only for testing purposes. They are not in torchtext requirements.
# torchtext should be installed along with : numpy, six, torch-[cg]pu
PYTHON_DEPS="certifi urllib3 chardet idna requests tqdm six numpy torch_cpu"

# Remove torch requirements as the user need to either install torch-[cg]pu wheel and not PyPI torch.
# Remove egg-info artefact as we are rebuilding a wheel.
PRE_BUILD_COMMANDS="sed -i -e \"s/'torch',//g\" setup.py; rm -r torchtext.egg-info;"

