import os
import sys
from setuptools import find_packages, setup

CURRENT_PYTHON = sys.version_info[:2]
REQUIRED_PYTHON = (3, 6)

# This check and everything above must remain compatible with Python 2.7.
if CURRENT_PYTHON < REQUIRED_PYTHON:
    sys.stderr.write("""
==========================
Unsupported Python version
==========================
This version of GPtools requires Python {}.{}, but you're trying to
install it on Python {}.{}.
""".format(*(REQUIRED_PYTHON + CURRENT_PYTHON)))
    sys.exit(1)

EXCLUDE_FROM_PACKAGES = []

# Dynamically calculate the version based on gptools.VERSION.
version = __import__('gptools').get_version()


def read(fname):
    with open(os.path.join(os.path.dirname(__file__), fname)) as f:
        return f.read()


setup(
    name='GPtools',
    version=version,
    python_requires='>={}.{}'.format(*REQUIRED_PYTHON),
    url='https://github.com/schiphol-Hub/GPTools/',
    author='Schiphol Stakeholder and Strategy Development',
    author_email='wouter.dalmeijer@schiphol.nl',
    description=('A Python toolbox that contains the common objects and '
                 'functions used for reporting and analysis at the Schiphol '
                 'department for Stakeholder and Strategy Development.'),
    long_description=read('README.md'),
    license='None',
    packages=find_packages(exclude=EXCLUDE_FROM_PACKAGES),
    include_package_data=True,
    install_requires=['pandas', 'numpy', 'scipy', 'xlrd', 'tables', 'matplotlib', 'pyshp'],
    zip_safe=False,
    project_urls={
        'Source': 'https://github.com/schiphol-Hub/GPTools/',
    },
)
