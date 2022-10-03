Use the following modules (on ulteosrv2 with CentOS 7):

pgi/20.7
netcdf-fortran/4.5.3

----------------------------------------------------------------------------------------------------
Handling NetCDF Libraries and Include Files

Portland Group (pgi) netcdf fortran libraries are located here:
/usr/global-7/sw/pgi/20.7/netcdf-fortran-4.5.3

The full path to netcdf.inc cannot be used in netcdfio.f because it is too long. Instead, create
a soft link in the parent directory containing computeCirc_v1.1, and use a relative path in the
include statements in netcdfio.f

For some reason, make_computeC cannot compile this program unless an absolute path is used for the
netcdf libraries. So use the full path to the netcdf libraries in make_computeC, not the soft link
used in netcdfio.f

Shawn Murdzek
27 July 2021
