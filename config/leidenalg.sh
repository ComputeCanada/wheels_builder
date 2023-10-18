MODULE_RUNTIME_DEPS='igraph'
PRE_BUILD_COMMANDS="
	bash scripts/build_libleidenalg.sh;
"
PATCHES='leidenalg-static-libleidenalg.patch'
