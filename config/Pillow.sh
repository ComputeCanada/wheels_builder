PYTHON_DEPS="olefile"
PYTHON_IMPORT_NAME="PIL"
if [[ -z $EBROOTGENTOO ]]; then
	PRE_BUILD_COMMANDS="sed -i -e 's;/sbin/ldconfig;ldconfig;g' setup.py && CPATH=$NIXUSER_PROFILE/include:$CPATH "
else
	PRE_BUILD_COMMANDS="sed -i -e 's;/sbin/ldconfig;ldconfig;g' setup.py && CPATH=$EBROOTGENTOO/include:$CPATH "
fi
