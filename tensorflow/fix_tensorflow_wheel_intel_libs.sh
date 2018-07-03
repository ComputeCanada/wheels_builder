#!/bin/bash

wheelname=$1
setrpaths.sh --path $wheelname --add_path $EBROOTIMKL/compilers_and_libraries/linux/lib/intel64_lin 
zip -d $wheelname $(unzip -l $wheelname | grep libiomp5.so | awk '{print $4}')

