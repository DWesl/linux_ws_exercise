#!/usr/bin/env python
from skbuild import setup

setup(
    packages=["computeCirc"],
    package_dir={"computeCirc": "src"},
    package_data={
        "computeCirc": [
            "*.nc", "*.csv", "*.input"
        ]
    },
    exclude_package_data={
        "computeCirc": [
            "*.dll",
            "**.dll",
            "_f_circ*.dll",
            "computeCirc/_f_circ*.dll"
        ]
    },
    data_files=[
        ("computeCirc", ["input/computeC.input"]),
    ],
    entry_points={
        "console_scripts": [
            "computeCirc = computeCirc.main:main"
        ]
    },
    cmake_source_dir="src",
)