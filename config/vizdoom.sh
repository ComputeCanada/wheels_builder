MODULE_BUILD_DEPS="cmake boost"
PRE_BUILD_COMMANDS="sed -i '"'s/"cmake",/"cmake","-DBoost_NO_BOOST_CMAKE=ON",/'"' setup.py"
