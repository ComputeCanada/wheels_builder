if [[ "$EBVERSIONGENTOO" == "2023" ]]; then
	    echo "Parasail python wheel is now bundled under the module of the same name since it depends on it at runtime."
        echo "use with : module load parasail"
        exit 1;
else
	MODULE_RUNTIME_DEPS="parasail"
	PRE_BUILD_COMMANDS="export PARASAIL_SKIP_BUILD=1"
fi
