# -*- coding: utf-8 -*-
"""Wrapper to run main function as package.

Allows ``python -m computeCirc``
"""
import sys

from .main import main

if __name__ == "__main__":
    sys.exit(main())
