MODULE_RUNTIME_DEPS='arrow/17'

if [[ $THIS_SCRIPT == 'build_wheel.sh' ]]; then
        echo "Closed source, only available as manylinux wheels. Using unmanylinuxize"
        echo ""

        module load gcc $MODULE_RUNTIME_DEPS
        bash unmanylinuxize.sh --package fireducks --version ${VERSION:?version required}
        exit 1;
fi

# Then one needs to manually set the correct rpath with

# for pv in 3.10 3.11 3.12;
# do
# 	module load gcc arrow/17 python/$pv
# 	unzip -d FIREDUCKS-$pv fireducks-1.0.7+computecanada-cp3${pv: -2}*.whl fireducks/fireducks_ext.so
# 	cd FIREDUCKS-$pv
# 	patchelf --set-rpath $EBROOTARROW/lib:$EBROOTARROW/lib/python${EBVERSIONPYTHON::4}/site-packages/pyarrow fireducks/fireducks_ext.so
# 	zip -v ../fireducks-1.0.7+computecanada-cp3${pv: -2}*.whl fireducks/fireducks_ext.so
# 	cd ..
# 	echo ""
# done
