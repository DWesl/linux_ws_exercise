bin_PROGRAMS=computeC

computeC_SOURCES=src/computeCirc/interp.f90 src/computeCirc/circ.f90 src/computeCirc/netcdfio.f src/computeCirc/main.f include/const.h
computeC_LDADD=@NETCDF4_FLIBS@ @NETCDF4_LIBS@
computeC_FFLAGS=@NETCDF4_FFLAGS@
computeC_FCFLAGS=@NETCDF4_FFLAGS@

MOSTLYCLEANFILES=netcdfio.mod circ.mod interp.mod

dist_data_DATA=input/computeC.input
