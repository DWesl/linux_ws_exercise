"""Calculate circulation for given files.

Read list of files and radius of circles for circulation calculations
from standard input.
"""
import ast
import configparser
import re
import sys

import circ
import netcdfio

C_SCALE = 1.0e-4

NAMELIST_PARSER = configparser.ConfigParser(
    inline_comment_prefixes="!", comment_prefixes="!"
)
NAMELIST_PARSER.SECTCRE = re.compile(r"\s*&(?P<header>\w+)\s*")

if __name__ == "__main__":
    NAMELIST_PARSER.read_file(sys.stdin)

    INPUTPARMS = NAMELIST_PARSER["inputparms"]
    N_FILES = INPUTPARMS.getint("nfiles")
    U_VARIABLE = ast.literal_eval(INPUTPARMS.get("u_variable"))[0]
    V_VARIABLE = ast.literal_eval(INPUTPARMS.get("v_variable"))[0]
    RADIUS = INPUTPARMS.getfloat("radius")
    # Will have to change this if someone uses array notation in their
    # namelist
    IN_FILES = [
        ast.literal_eval(val)[0]
        for key, val in INPUTPARMS.items()
        if key.startswith("infile")
    ]

    for in_file_name in IN_FILES:
        print("Computing circulation...")  # noqa: T001
        nx, ny, nz, nv = netcdfio.getsize(in_file_name)
        dx, dy, dz, x, y, z = netcdfio.getgridinfo(in_file_name, nx, ny, nz)

        u = netcdfio.netcdf_read(U_VARIABLE, in_file_name, nx, ny, nz)
        v = netcdfio.netcdf_read(V_VARIABLE, in_file_name, nx, ny, nz)

        circulation = circ.getcirc(u, v, x, y, z, dx, dy, dz, nx, ny, nz, RADIUS)

        circulation = circulation * C_SCALE

        print("Done\n\nWriting data to netcdf file")  # noqa: T001

        label = "CIRC"
        istatus = netcdfio.varinq(label, in_file_name)
        if not istatus:
            netcdfio.netcdf_write(circulation, label, in_file_name, nx, ny, nz)
        else:
            netcdfio.netcdf_overwrite(circulation, label, in_file_name, nx, ny, nz)

        print("Done\n\nOperation completed for", in_file_name, "\n\n")  # noqa: T001
