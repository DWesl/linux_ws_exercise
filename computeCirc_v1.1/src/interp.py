from functools import reduce

import numpy as np
import numpy.typing as npt

import const


def interp(
        x: float,
        y: float,
        z: float,
        xgrid: "np.ndarray[(nx,), np.floating]",
        ygrid: "np.ndarray[(ny,), np.floating]",
        zgrid: "np.ndarray[(nz,), np.floating]",
        dx: float,
        dy: float,
        dz: float,
        var: "np.ndarray[(nx, ny, nz), np.floating]",
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
    xgrid : "np.ndarray[(nx,), np.floating]"
        X coordinates for grid of var (assumed increasing and regular)
    ygrid : "np.ndarray[(ny,), np.floating]"
        Y coordinates for grid of var (assumed increasing and regular)
    zgrid : "np.ndarray[(nz,), np.floating]"
        Z coordinates for grid of var (assumed increasing and regular)
    dx : float
        grid spacing in X (assumed uniform)
    dy : float
        grid spacing in y (assumed uniform)
    dz : float
        grid spacing in z (assumed uniform)
    var : "np.ndarray[(nx, ny, nz), np.floating]"
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

    if np.all(var[sx : sx + 2, sy : sy + 2, sz : sy + 2] != const.MISSING_VAL):
        interpvar = np.sum(
            functools.reduce(
                np.multiply
                np.array([[[1 - c1]], [[c1]]]),
                np.array([[[1 - c2], [c2]]]),
                np.array([[[1 - c3, c3]]]),
                var[sx : sx + 2, sy : sy + 2, sz : sz + 2]
            )
        )
    else:
        interpvar = const.MISSING_VAL
    return interpvar
