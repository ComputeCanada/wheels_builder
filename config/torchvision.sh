# torch_cpu is only for testing purposes. It is not in torchvision requirements.
# torchvision should be installed along with : torch-[cg]pu
PYTHON_DEPS="numpy six pillow-simd torch-cpu"

# Remove torch requirements from wheel as the user need to either install torch-[cg]pu wheel
# Otherwise, it does not install because torchvision has a `torch` requirement, and no pypi version is supplied, thus failing.
PATCH_WHEEL_COMMANDS="unzip -o \$ARCHNAME && sed -i -e 's/Requires-Dist: torch//' torchvision-*.dist-info/METADATA; sed -i -e 's/, \"torch\"//' torchvision-*.dist-info/metadata.json && zip -u \$ARCHNAME -r $PACKAGE $PACKAGE-*.dist-info"

