if [[ $THIS_SCRIPT == 'unmanylinuxize.sh' ]]; then
	PATCH_WHEEL_COMMANDS="
	    unzip -q -o \$ARCHNAME triton/backends/nvidia/compiler.py;
	    patch triton/backends/nvidia/compiler.py $SCRIPT_DIR/patches/triton-nvidia-compiler.patch;
	    zip \$ARCHNAME triton/backends/nvidia/compiler.py;
	"
fi
