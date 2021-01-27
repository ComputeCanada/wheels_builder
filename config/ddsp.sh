PYTHON_DEPS="tensorflow_cpu"
# The universal wheel is downloaded so patch it to use tf_cpu.
PATCH_WHEEL_COMMANDS="unzip \$ARCHNAME && sed -i -e 's/^Requires-Dist: tensorflow$/Requires-Dist: tensorflow_cpu/' ddsp-*/METADATA && zip \$ARCHNAME ddsp-*/METADATA"
