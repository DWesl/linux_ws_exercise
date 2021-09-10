FC=gfortran

NETCDF_INC:=$(shell nf-config --fflags)

NETCDF_LIBS:=$(shell nf-config --flibs)

SRCS:=$(wildcard *.f)
OBJS:=$(subst .f,.o,$(SRCS))

all: computeC

.PHONY: all

computeC: $(OBJS)
	$(FC) -o $@ $(OBJS) $(NETCDF_LIBS)

.f.o:
	$(FC) $(NETCDF_INC) -c -o $@ $<

clean:
	rm $(OBJS) computeC
