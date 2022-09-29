import ast
import configparser
import re
import sys

import circ
import const
import netcdfio

C_SCALE = 1.e-4

NAMELIST_PARSER = configparser.ConfigParser(inline_comment_prefixes="!", comment_prefixes="!")
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
        for key, val in parser["inputparms"].items() if key.startswith("infile")
    ]

    for in_file_name in IN_FILES:
        print("Computing circulation...")
        nx, ny, nz, nv = netcdfio.getsize(in_file_name)
        dx, dy, dz, x, y, z = netcdfio.getgridinfo(in_file_name, nx, ny, nz)

        u = netcdfio.netcdf_read(u_variable, in_file_name, nx, ny, nz)
        v = netcdfio.netcdf_read(v_variable, in_file_name, nx, ny, nz)

        circ = circ.getcirc(u, v, x, y, z, dx, dy, dz, nx, ny, nz, radius)

        circ = circ * C_SCALE

        print("Done\n\nWriting data to netcdf file")

        label = "CIRC"
        istatus = netcdfio.varinq(label, in_file_name)
        if not istatus:
            netcdfio.netcdf_write(circ, label, in_file_name, nx, ny, nz)
        else:
            netcdfio.netcdf_overwrite(circ, label, in_file_name, nx, ny, nz)

        print("Done\n\nOperation completed for", in_file_name, "\n\n")
