from setuptools import setup
import os

with open('README.md', 'r') as fp:
    readme = fp.read()

if os.environ.get('EBVERSIONCMAKE'):
    version = os.environ.get('EBVERSIONCMAKE')
    print(f'Using version from module: {version}')
elif os.environ.get('VERSION'):
    version = os.environ.get('VERSION')
    print(f'Forcing version : {version}')
else:
    print(f'No version set. Set VERSION=x.y.z')
    exit(1)

setup(
    description="CMake dummy wheel. Empty shell that does nothing except fulfill the requirement.",
    name="cmake",
    version=f"{version}+dummy.computecanada",
    long_description=readme
)
