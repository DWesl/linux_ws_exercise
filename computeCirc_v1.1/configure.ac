#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([computeC], [1.1], [Shawn Murdzek and Paul Markowski])
AC_CONFIG_SRCDIR([include/const.h])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([-Wall foreign dist-xz subdir-objects])

# Checks for programs.
AC_PROG_CC
AC_PROG_F77

# Checks for libraries.
AX_LIB_NETCDF4(serial)

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
