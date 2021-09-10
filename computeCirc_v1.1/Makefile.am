bin_PROGRAMS=computeC

computeC_SOURCES=src/circ.f src/interp.f src/netcdfio.f src/main.f include/const.h
computeC_LDADD=@NETCDF4_FLIBS@ @NETCDF4_LIBS@
computeC_FFLAGS=@NETCDF4_FFLAGS@

dist_data_DATA=input/computeC.input
