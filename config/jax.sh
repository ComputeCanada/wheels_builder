# Jax requires Jaxlib to run. Because there's multiple version of jaxlib, the dependency is an extra requirement
# not being mandatory. Ensure jax require the minimum compatible jaxlib version up to the current available one!
PRE_BUILD_COMMANDS="sed -i -e \"s/install_requires=\[/install_requires=\[f'jaxlib>={_minimum_jaxlib_version},<={_current_jaxlib_version}',/\" setup.py"
