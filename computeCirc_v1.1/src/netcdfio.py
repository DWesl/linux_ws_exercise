# -*- coding: utf-8 -*-
"""Functions for interacting with netCDF files.

Simple wrappers around netCDF4 calls, mostly.
"""
from typing import Tuple

import netCDF4  # type: ignore
import numpy as np
import numpy.typing as npt


def getsize(filename: str) -> Tuple[int, int, int, int]:
    """Get size and number of variables from file.

    Parameters
    ----------
    filename : str
        File name to check

    Returns
    -------
    nx : int
        Number of points in x direction
    ny : int
        Number of points in y direction
    nz : int
        Number of points in z direction
    nv : int
        Number of variables
    """
    with netCDF4.Dataset(filename, "r") as ncds:
        nx = ncds.dimensions["x"].size
        ny = ncds.dimensions["y"].size
        nz = ncds.dimensions["z"].size
        nv = ncds.dimensions["fields"].size

    return nx, ny, nz, nv


def getgridinfo(
    filename: str, nx: int, ny: int, nz: int
) -> Tuple[
    float,
    float,
    float,
    "npt.NDArray[np.floating]",  # noqa: F821
    "npt.NDArray[np.floating]",  # noqa: F821
    "npt.NDArray[np.floating]",  # noqa: F821
]:
    """Get grid information from file.

    Parameters
    ----------
    filename : str
        Name of file
    nx : int
        Number of points in x direction
    ny : int
        Number of points in y direction
    nz : int
        Number of points in z direction

    Returns
    -------
    dx : float
    dy : float
    dz : float
    x : np.ndarray[(nx,), np.floating]
    y : np.ndarray[(ny,), np.floating]
    z : np.ndarray[(nz,), np.floating]
    """
    with netCDF4.Dataset(filename, "r") as ncds:
        x = ncds.variables["x"][:]
        y = ncds.variables["y"][:]
        z = ncds.variables["z"][:]
        dx = ncds.variables["x_spacing"][:]
        dy = ncds.variables["y_spacing"][:]
        dz = ncds.variables["z_spacing"][:]
    return dx, dy, dz, x, y, z


def getvarnames(filename: str, nv: int) -> "npt.NDArray[np.unicode_]":  # noqa: F821
    """Get a list of variables in a netCDF file.

    Parameters
    ----------
    filename : str
        File name
    nv : int
        Number of variables

    Returns
    -------
    np.ndarray[(nv,), str]
        Variable names

    Examples
    --------
    FIXME: Add docs.
    """
    with netCDF4.Dataset(filename, "r") as ncds:
        name_length = 8
        field_names: npt.NDArray[np.floating] = np.char.rstrip(
            ncds.variables["field_names"][:].view("S{:d}".format(name_length))[:, 0]
        )
    return np.char.decode(field_names, "ascii")


def netcdf_read(
    varname: str, filename: str, nx: int, ny: int, nz: int
) -> "npt.NDArray[np.floating]":  # noqa: F821
    """Get variable from file.

    Parameters
    ----------
    varname : str
        Name of variable to get
    filename : str
        Name of file to get from which to get variable
    nx : int
        Number of points in x direction
    ny : int
        Number of points in y direction
    nz : int
        Number of points in z direction

    Returns
    -------
    np.ndarray[(nz, ny, nx), np.floating]
        Variable values

    Examples
    --------
    FIXME: Add docs.
    """
    with netCDF4.Dataset(filename, "r") as ncds:
        val: npt.NDArray[np.floating] = ncds.variables[varname][:]
    return val


def netcdf_overwrite(
    val: "npt.NDArray[np.floating]",  # noqa: F821
    varname: str,
    filename: str,
    nx: int,
    ny: int,
    nz: int,
) -> None:
    """Overwrite variable values in file.

    Parameters
    ----------
    val : np.ndarray[(nz, ny, nx), np.floating]
        The values to write
    varname : str
        The variable name to overwrite
    filename : str
        The filename in which to replace the variable
    nx : int
        Number of points in x direction
    ny : int
        number of points in y direction
    nz : int
        number of points in z direction

    See Also
    --------
    netcdf_write

    Examples
    --------
    FIXME: Add docs.
    """
    with netCDF4.Dataset(filename, "a") as ncds:
        ncds.variables[varname][:] = val


def netcdf_write(
    val: "npt.NDArray[np.floating]",  # noqa: F821
    varname: str,
    filename: str,
    nx: int,
    ny: int,
    nz: int,
) -> None:
    """Write a new variable to netCDF file.

    If variable already exists, call :py:func:`netcdf_overwrite`
    instead.

    Parameters
    ----------
    val : "np.ndarray[(nz, ny, nx), np.floating]"
        The values of the variable
    varname : str
        The name of the variable
    filename : str
        The name of the file
    nx : int
        number of points in x direction
    ny : int
        number of points in y direction
    nz : int
        number of points in z direction

    See Also
    --------
    netcdf_overwrite

    Examples
    --------
    FIXME: Add docs.
    """
    with netCDF4.Dataset(filename, "a") as ncds:
        old_last_var_name = (
            b"".join(ncds.variables["field_names"][-1, :]).strip().decode("ascii")
        )
        old_last_var = ncds.variables[old_last_var_name]
        new_var = ncds.createVariable(
            varname, old_last_var.dtype, old_last_var.dimensions
        )
        for att_name in old_last_var.ncattrs():
            new_var.setncattr(att_name, old_last_var.getncattr(att_name))
        new_var[:] = val


def varinq(varname: str, filename: str) -> bool:
    """Check whether variable already exists in file.

    Parameters
    ----------
    varname : str
        Name to check for
    filename : str
        File to check

    Returns
    -------
    bool
        Whether the variable is in the file

    Examples
    --------
    FIXME: Add docs.
    """
    # field_names = getvarnames(filename)
    # return np.in1d(varname, field_names)[0]
    with netCDF4.Dataset(filename, "r") as ncds:
        result = varname in ncds.variables
    return result
