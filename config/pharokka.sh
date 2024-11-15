PATCHES='pharokka-fix_mmseqs2.patch'
PRE_BUILD_COMMANDS="sed -i -e \"/install_requires=/a 'dnaapler>=0.4.0',\" setup.py"
