MODULE_BUILD_DEPS='eigen boost qt/5 muparser cgal'
PACKAGE_DOWNLOAD_ARGUMENT="git+https://github.com/cnr-isti-vclab/PyMeshLab.git@v${VERSION:?version required}"
PRE_BUILD_COMMANDS="
    cmake -B _build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=\$PWD/pymeshlab &&
    cmake --build _build --parallel ${SLURM_CPUS_PER_TASK:-1} && cmake --install _build &&
    setrpaths --path pymeshlab --add_path '\$ORIGIN/lib:\$ORIGIN/..' --any_interpreter;
    sed -i -e 's/return a, b, platform_tag/return a, b, c/' setup.py;
"
