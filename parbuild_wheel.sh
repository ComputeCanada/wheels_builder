#!/bin/bash

# Build multiple versions of a wheel in parallel.
# Usage: bash parbuild_wheel.sh cupy "6.4.0 5.3.0" "3.7 3.6 3.5"
# To terminate, ctrl+c or `killall -TERM parallel`

function ls_pythons()
{
	ls -1d /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/3* | grep -Po "\d\.\d" | sort -u
}

wheel=${1?Missing wheel}
versions=${2?Missing versions}
pythons=${3-$(ls_pythons)}

# Yes, two times the command, display what will be run and then run it.
cmd="PYTHON_VERSIONS="python/{1}" bash build_wheel.sh ${wheel} {2} |& tee build-${wheel}-{2}-py{1}.log ::: ${pythons} ::: ${versions}"
parallel --dry-run $cmd
parallel           $cmd
