PYTHON_DEPS="cffi"
MODULE_RUNTIME_DEPS="samtools minimap2"
PRE_BUILD_COMMANDS="sed -i 's/tensorflow~=2.2.2/tensorflow_cpu==2.2.*/' requirements.txt && export LDFLAGS=-ldeflate"
