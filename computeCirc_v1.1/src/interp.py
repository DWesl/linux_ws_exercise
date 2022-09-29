"""3-D interpolation function.

This could be a simple wrapper around
:py:func:`scipy.interpolate.interpn`, but I don't know if that
dependency is something I want to add.

It might be possible to rewrite as a list of calls to
:py:func:`numpy.interp`, but that's tricky.
"""
from functools import reduce

import numpy as np
import numpy.typing as npt

import const


def interp(
    x: float,
    y: float,
    z: float,
    xgrid: "npt.NDArray[np.floating]",  # noqa: F821
    ygrid: "npt.NDArray[np.floating]",  # noqa: F821
    zgrid: "npt.NDArray[np.floating]",  # noqa: F821
    dx: float,
    dy: float,
    dz: float,
    var: "npt.NDArray[np.floating]",  # noqa: F821
    nx: int,
    ny: int,
    nz: int,
) -> float:
    """Interpolate field var to location x, y, z.

    Parameters
    ----------
    x : float
        X location for interpolation
    y : float
        Y location for interpolation
    z : float
        Z location for interpolation
    xgrid : "npt.NDArray[(nx,), np.floating]"
        X coordinates for grid of var (assumed increasing and regular)
    ygrid : "npt.NDArray[(ny,), np.floating]"
        Y coordinates for grid of var (assumed increasing and regular)
    zgrid : "npt.NDArray[(nz,), np.floating]"
        Z coordinates for grid of var (assumed increasing and regular)
    dx : float
        grid spacing in X (assumed uniform)
    dy : float
        grid spacing in y (assumed uniform)
    dz : float
        grid spacing in z (assumed uniform)
    var : "npt.NDArray[(nx, ny, nz), np.floating]"
        Field to interpolated; assumed defined on regular grid.
    nx : int
        Number of points in x direction
    ny : int
        number of points in y direction
    nz : int
        number of points in z direction

    Returns
    -------
    float
        Field value at location (x, y, z)

    Examples
    --------
    FIXME: Add docs.
    """
    sx = int((x - xgrid[0]) / dx)
    sy = int((y - ygrid[0]) / dy)
    sz = int((z - zgrid[0]) / dz)

    c1 = (x - xgrid[sx]) / dx
    c2 = (y - ygrid[sy]) / dy
    c3 = (z - zgrid[sz]) / dz

    interpvar: float = const.MISSING_VAL
    if np.all(var[sz : sz + 2, sy : sy + 2, sx : sx + 2] != const.MISSING_VAL):
        interpvar = np.sum(
            reduce(
                np.multiply,
                [
                    np.array([[[1 - c1]], [[c1]]]),
                    np.array([[[1 - c2], [c2]]]),
                    np.array([[[1 - c3, c3]]]),
                    var[..., sz : sz + 2, sy : sy + 2, sx : sx + 2],
                ],
            )
        )
    return interpvar
