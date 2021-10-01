MODULE_RUNTIME_DEPS="cuda faiss"
PATCH_WHEEL_COMMANDS="$SCRIPT_DIR/manipulate_wheels.py -v --inplace --force -w \$ARCHNAME -u 'faiss-cpu->faiss'"
