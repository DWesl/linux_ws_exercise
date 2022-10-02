bin_PROGRAMS=computeC

computeC_SOURCES=src/interp.f90 src/circ.f90 src/netcdfio.f src/main.f include/const.h
computeC_LDADD=@NETCDF4_FLIBS@ @NETCDF4_LIBS@
computeC_FFLAGS=@NETCDF4_FFLAGS@
computeC_FCFLAGS=@NETCDF4_FFLAGS@

dist_data_DATA=input/computeC.input
