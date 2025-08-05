MODULE_RUNTIME_DEPS="
    scipy-stack/2025a
    nlopt/2
"
MODULE_BUILD_DEPS="
    cuba/4.2.2
    eigen/3.4.0
    flexiblas/3
    primme/3.2
    nlopt/2
"
PRE_BUILD_COMMANDS='
    sed -e s/\${PROJECT_VERSION}/$VERSION/ -i CMakeLists.txt;
    export CMAKE_ARGS="
        -DBLA_VENDOR=FlexiBLAS
        -DEIGEN_HAMILTONIAN=1
        -DWITH_PRIMME=1
        -DPRIMME_DIR=$EBROOTPRIMME
        -DCUBA_DIR=$EBROOTCUBA
        -DWITH_GF_OPT_KERNEL=1
    "
'
