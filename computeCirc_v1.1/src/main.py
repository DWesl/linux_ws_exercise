#!/usr/bin/env python
"""Calculate circulation for given files.

Read list of files and radius of circles for circulation calculations
from standard input.
"""
import ast
import configparser
import io
import re
import sys

import numpy as np

from . import circ
from . import const
from . import netcdfio

C_SCALE = 1.0e-4


def parse_namelist(fileptr: "io.TextIOBase") -> configparser.ConfigParser:
    """Parse a namelist.

    Parameters
    ----------
    fileptr : file
        A file containing a namelist

    Returns
    -------
    configparser.ConfigParser
        The parsed namelist

    Examples
    --------
    FIXME: Add docs.

    See Also
    --------
    f20nml
        An alternate and more robust namelist parser.
    """
    namelist_parser = configparser.ConfigParser(
        inline_comment_prefixes="!",
        comment_prefixes="!",
        converters={
            "int": lambda val: int(val.rstrip(",")),
            "float": lambda val: float(val.rstrip(",")),
            "string": lambda val: ast.literal_eval(val.rstrip(",")),
        },
    )
    namelist_parser.SECTCRE = re.compile(r"\s*&(?P<header>\w+)\s*")

    namelist_parser.read_file(fileptr)
    return namelist_parser

def compute_circulation(fileptr: io.TextIOBase):
    namelist_parser = parse_namelist(fileptr)
    inputparms = namelist_parser["inputparms"]
    n_files = inputparms.getint("nfiles")
    u_variable = inputparms.getstring("u_variable")
    v_variable = inputparms.getstring("v_variable")
    radius = inputparms.getfloat("radius")
    # will have to change this if someone uses array notation in their
    # namelist
    in_files = [
        inputparms.getstring(key)
        for key in inputparms.keys()
        if key.startswith("infile")
    ]

    for in_file_name in in_files:
        print("computing circulation...")  # noqa: t001
        nx, ny, nz, nv = netcdfio.getsize(in_file_name)
        dx, dy, dz, x, y, z = netcdfio.getgridinfo(in_file_name, nx, ny, nz)

        u = netcdfio.netcdf_read(u_variable, in_file_name, nx, ny, nz)
        v = netcdfio.netcdf_read(v_variable, in_file_name, nx, ny, nz)

        circulation = circ.getcirc(
            u[0], v[0], x, y, z, dx, dy, dz, radius, nx, ny, nz
        )

        circulation *= C_SCALE

        print("Done\n\nWriting data to netcdf file")  # noqa: T001

        label = "CIRC"
        istatus = netcdfio.varinq(label, in_file_name)
        if not istatus:
            netcdfio.netcdf_write(circulation, label, in_file_name, nx, ny, nz)
        else:
            netcdfio.netcdf_overwrite(circulation, label, in_file_name, nx, ny, nz)

        print("Done\n\nOperation completed for", in_file_name, "\n\n")  # noqa: T001


def main() -> int:
    compute_circulation(sys.stdin)
    return 0


if __name__ == "__main__":
    sys.exit(main())
