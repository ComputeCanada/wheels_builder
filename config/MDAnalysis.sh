PYTHON_DEPS="gsd Cython joblib numpy mock GridDataFormats scipy matplotlib networkx biopython mmtf-python six duecredit"
# keyword "provides" makes problems with wheelfile package [1]
# and is also ignored by pip [2], so we just comment it out.
# [1] https://github.com/MrMino/wheelfile/issues/13
# [2] https://setuptools.pypa.io/en/latest/references/keywords.html
PRE_BUILD_COMMANDS="sed -i 's/provides=/# provides=/' setup.py ; "
