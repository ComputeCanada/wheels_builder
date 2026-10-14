MODULE_RUNTIME_DEPS="vtk/9.3"
PATCH_WHEEL_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --remove_req pyvista[jupyter] --update_req pyvista~=0.44 --wheels $ARCHNAME'
