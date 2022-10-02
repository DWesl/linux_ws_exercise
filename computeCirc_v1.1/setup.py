#!/usr/bin/env python
from skbuild import setup

setup(
    packages="computeCirc",
    package_dir={"src": "computeCirc"},
    entry_points={
        "console_scripts": [
            "computeCirc = computeCirc.main:main"
        ]
    },
    cmake_source_dir="src",
)
