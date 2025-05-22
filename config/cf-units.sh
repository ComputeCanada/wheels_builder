MODULE_BUILD_DEPS='udunits'
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/SciTools/cf-units/archive/refs/tags/v${VERSION:?version required}.zip"
PRE_BUILD_COMMANDS='
	export UDUNITS2_INCDIR=$EBROOTUDUNITS/include;
	export UDUNITS2_LIBDIR=$EBROOTUDUNITS/lib;
	export UDUNITS2_XML_PATH=$EBROOTUDUNITS/share/udunits/udunits2.xml;
'
