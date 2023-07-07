# Note that this package is deprecated in favor of the leidenalg package
MODULE_RUNTIME_DEPS='igraph'
if [[ $VERSION == '0.7.2' ]]; then
	MODULE_RUNTIME_DEPS='igraph/0.9'
fi
BDIST_WHEEL_ARGS=' --use-pkg-config --external'
