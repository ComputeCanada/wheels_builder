PATCH_WHEEL_COMMANDS="unzip -q -o \$ARCHNAME && sed -i -e 's/^Requires-Dist: tensorflow /Requires-Dist: tensorflow_cpu /' tensorflow_io-*/METADATA && zip \$ARCHNAME tensorflow_io-*/METADATA"
