PYTHON_DEPS="cffi"
MODULE_RUNTIME_DEPS="samtools minimap2"
PRE_BUILD_COMMANDS="sed -i 's/tensorflow~=2.5.2/tensorflow==2.5.*/' requirements.txt && export LDFLAGS=-ldeflate"
