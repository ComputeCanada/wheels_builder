if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
        echo 'GRPCIO suffers from an infinite hang when built from source. Stubbornely not building from source!'; 
        echo 'See https://github.com/ComputeCanada/wheels_builder/issues/41'
        exit 1;
fi

PYTHON_IMPORT_NAME="grpc"

