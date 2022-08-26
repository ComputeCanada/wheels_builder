PYTHON_DEPS="cvxpy cvxopt joblib numexpr osqp pandas scikit-learn==0.23.0 scipy>=1.0"
PYTHON_IMPORT_NAME="sksurv"
PATCHES="scikit_survival-${VERSION}.patch"

if [ -z ${VERSION} ] ; then
	echo "Build scikit-survival with an explicit version (--version)."
	echo 'Also make sure that the patch "patches/scikit_survival-${VERSION}.patch" exists'
	exit 1
elif [ ! -e "$(dirname $0)/patches/scikit_survival-${VERSION}.patch" ] ; then
	echo 'Make sure that the patch "patches/scikit_survival-${VERSION}.patch" exists'
	exit 1
fi
