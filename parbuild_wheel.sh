#!/bin/bash

function ls_pythons()
{
	ls -1d /cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/python/3* | grep -Po "\d\.\d" | sort -u
}

wheel=${1?Missing wheel}
versions=${2?Missing versions}
pythons=${3-$(ls_pythons)}

# Yes, two times the command, display what will be run and then run it.
parallel --dry-run PYTHON_VERSIONS="python/{1}" bash build_wheel.sh ${wheel} {2} "|&" tee build-${wheel}-{2}-py{1}.log ::: "${pythons}" ::: "${versions}"
parallel           PYTHON_VERSIONS="python/{1}" bash build_wheel.sh ${wheel} {2} "|&" tee build-${wheel}-{2}-py{1}.log ::: "${pythons}" ::: "${versions}"
