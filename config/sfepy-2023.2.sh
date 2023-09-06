MODULE_BUILD_DEPS="gcc cmake"
PATCHES="sfepy-2023.2.patch"
# pin numpy and scipy versions so that it doesn't pull in the latest numpy.
# According to NEP29, NumPy 1.22 is the oldest supported version as of June 23, 2023.
# https://numpy.org/neps/nep-0029-deprecation_policy.html#support-table
PYTHON_DEPS="numpy~=1.22.4 scipy<1.10 ninja matplotlib tables meshio"
PACKAGE_DOWNLOAD_NAME="${PACKAGE}-${VERSION}.tar.gz"

