PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/scilus/scilpy.git@$VERSION"
MODULE_RUNTIME_DEPS="vtk"
# Relax constraints as they are incompatible
PRE_BUILD_COMMANDS="sed -i -e 's/[=>]=.*$//' requirements.txt"
