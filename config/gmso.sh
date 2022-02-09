PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mosdef-hub/gmso/archive/refs/tags/${VERSION}.tar.gz"
PYTHON_DEPS="numpy~=$NUMPY_DEFAULT_VERSION sympy unyt boltons lxml pydantic<1.9.0 networkx ele"
PATCHES="gmso.patch"
if [[ "$VERSION" == "0.7.3" ]]; then
  # they forgot to change this flag, causing .dev0 to be added to the version
  PRE_BUILD_COMMANDS="sed -i 's/ISRELEASED = False/ISRELEASED = True/' setup.py"
fi

