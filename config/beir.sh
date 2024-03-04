MODULE_RUNTIME_DEPS="cuda/11.4 faiss arrow"
PATCH_WHEEL_COMMANDS="$SCRIPT_DIR/manipulate_wheels.py -v --inplace --force -w \$ARCHNAME -u 'faiss-cpu->faiss'"
