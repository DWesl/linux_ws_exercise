"""Calculate curculation for a wind field."""
import math

import numpy as np

import const
import interp

N_AZIMUTHS = 72


def getcirc(
    u: "np.ndarray[(nz, ny, nx), np.floating]",  # noqa: F821
    v: "np.ndarray[(nz, ny, nx), np.floating]",  # noqa: F821
    x: "np.ndarray[(nx,), np.floating]",  # noqa: F821
    y: "np.ndarray[(ny,), np.floating]",  # noqa: F821
    z: "np.ndarray[(nz,), np.floating]",  # noqa: F821
    dx: float,
    dy: float,
    dz: float,
    nx: int,
    ny: int,
    nz: int,
    radius: float,
) -> "np.ndarray[(nz, ny, nx), np.floating]":  # noqa: F821
    """Calculate circulation around each point.

    Uses circles of the given radius for calculating circulation

    Parameters
    ----------
    u : "np.ndarray[(nz, ny, nx), np.floating]"
        x component of wind
    v : "np.ndarray[(nz, ny, nx), np.floating]"
        y component of wind
    x : "np.ndarray[(nx,), np.floating]"
        x coordinates of grid
    y : "np.ndarray[(ny,), np.floating]"
        y coordinates of grid
    z : "np.ndarray[(nz,), np.floating]"
        z coordinates
    dx : float
        grid spacing in x direction
    dy : float
        grid spacing in y direction
    dz : float
        grid spacing in z direction
    nx : int
        number of points in x direction
    ny : int
        number of points in y direction
    nz : int
        number of points in z direction
    radius : float
        radius of circle around which to calculate circulation

    Returns
    -------
    "np.ndarray[(nz, ny, nx), np.floating]"
        Circulation around each point

    Examples
    --------
    FIXME: Add docs.
    """
    circ = np.full_like(u, const.MISSING_VAL)
    y_space = math.ceil(radius / dy)
    x_space = math.ceil(radius / dx)
    for k in range(nz - 1):
        for j in range(y_space, ny - y_space):
            for i in range(x_space, nx - x_space):
                sumVt = 0.0
                angles = np.linspace(0, 2 * const.PI, N_AZIMUTHS + 1)[:-1]
                xtmps = x[i] + radius * np.cos(angles)
                ytmps = y[j] + radius * np.sin(angles)
                tangents_x = -np.sin(angles)
                tangents_y = np.cos(angles)
                for xtmp, ytmp, tan_x, tan_y in zip(
                    xtmps, ytmps, tangents_x, tangents_y
                ):
                    utmp = interp.interp(
                        xtmp, ytmp, z[k], x, y, z, dx, dy, dz, u, nx, ny, nz
                    )
                    vtmp = interp.interp(
                        xtmp, ytmp, z[k], x, y, z, dx, dy, dz, v, nx, ny, nz
                    )
                    if utmp == const.MISSING_VAL or vtmp == const.MISSING_VAL:
                        break
                    sumVt = sumVt + utmp * tan_x + vtmp * tan_y
                else:
                    circ[k, j, i] = (
                        sumVt * (2 * const.PI * radius / N_AZIMUTHS) * const.KM2M
                    )
    return circ
