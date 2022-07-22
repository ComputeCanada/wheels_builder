# Link against our module when possible.
# Provide a wheel even if we could add the bindings to the module as
# so so many packages depends on this it is preferable to avoid the wave of tickets
# and provide an optimize wheel.
MODULE_BUILD_DEPS='protobuf/3.19.4'
PYTHON_IMPORT_NAME="google.protobuf"
BDIST_WHEEL_ARGS="--cpp_implementation"
