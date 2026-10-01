PYTHON_DEPS="cffi"
MODULE_RUNTIME_DEPS="samtools minimap2 parasail"
PRE_BUILD_COMMANDS="
    export LDFLAGS=-ldeflate;
    sed -i -e 's/ont-parasail/parasail/' -e 's/pysam>=0.16.0.1,<=0.23.0/pysam>=0.16.0.1/' requirements.txt;

"
