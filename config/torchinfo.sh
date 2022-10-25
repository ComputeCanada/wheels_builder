PYTHON_DEPS="torch torchvision"
PRE_BUILD_COMMANDS="sed -i \"s/setup()/setup(install_requires=['torch', 'torchvision'])/\" setup.py"
