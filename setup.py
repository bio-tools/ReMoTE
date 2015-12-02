#!/usr/bin/env python
# -*- coding: utf-8 -*-

#from distutils.core import setup
import glob
from setuptools import setup

readme = open('README.md').read()

setup(
    name='ReMoTE',
    version='0.1',
    description='Registration of Mobyle Tools in Elixir',
    long_description=readme,
    author='Hervé Ménager',
    author_email='hmenager@pasteur.fr',
    url='https://github.com/bioinfo-center-pasteur-fr/ReMoTE.git',
    packages=['remote'],
    install_requires=[
          'lxml','requests'
    ],
    license="BSD",
    entry_points={
          'console_scripts': ['remote=remote:main'],
        },
    include_package_data=True,
    zip_safe=False 
)
