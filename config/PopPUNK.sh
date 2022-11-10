PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/bacpop/PopPUNK/archive/refs/tags/v${VERSION:?version required}.tar.gz"
MODULE_BUILD_DEPS='python-build-bundle cmake eigen flexiblas'
MODULE_RUNTIME_DEPS='graph-tool'
PRE_BUILD_COMMANDS="
        sed -i 's/openblas/flexiblas/' CMakeLists.txt;
        sed -i \"/^setup(/a install_requires=['biopython', 'h5py', 'hdbscan', 'matplotlib', 'mandrake', 'networkx', 'pandas', 'pp-sketchlib\>=1.7.0', 'requests', 'scikit-learn\>=0.24', 'tqdm', 'treeswift'],\" setup.py
"
