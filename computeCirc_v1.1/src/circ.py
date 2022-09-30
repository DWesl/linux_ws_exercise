"""Calculate curculation for a wind field.

This is calculated on a circle around each point in the domain where
the circle will fit.
"""
import math

import numexpr as ne
import numpy as np
import numpy.typing as npt

import const
import interp

N_AZIMUTHS = 72


def getcirc(
    u: "npt.NDArray[np.floating]",  # noqa: F821
    v: "npt.NDArray[np.floating]",  # noqa: F821
    x: "npt.NDArray[np.floating]",  # noqa: F821
    y: "npt.NDArray[np.floating]",  # noqa: F821
    z: "npt.NDArray[np.floating]",  # noqa: F821
    dx: float,
    dy: float,
    dz: float,
    nx: int,
    ny: int,
    nz: int,
    radius: float,
) -> "npt.NDArray[np.floating]":  # noqa: F821
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
    y_space = math.ceil(radius / dy)
    x_space = math.ceil(radius / dx)
    angles = np.linspace(0, 2 * const.PI, N_AZIMUTHS + 1)[:-1]
    circle_displacement_x = radius * np.cos(angles)
    circle_displacement_y = radius * np.sin(angles)
    tangents_x = -np.sin(angles)
    tangents_y = np.cos(angles)
    ds_x = tangents_x * (2 * const.PI * radius / N_AZIMUTHS) * const.KM2M
    ds_y = tangents_y * (2 * const.PI * radius / N_AZIMUTHS) * const.KM2M

    y_grid, x_grid = np.meshgrid(y, x, indexing="ij")
    interpolation_y = y_grid[..., np.newaxis] + circle_displacement_y
    interpolation_x = x_grid[..., np.newaxis] + circle_displacement_x

    interpolation_indexer = (slice(y_space, -y_space), slice(x_space, -x_space))

    four_dim_u = True
    if u.ndim == 3:
        four_dim_u = False
        u = u[np.newaxis, ...]
        v = v[np.newaxis, ...]

    u = np.where(u == const.MISSING_VAL, np.nan, u)
    v = np.where(v == const.MISSING_VAL, np.nan, v)

    circ = np.full_like(u, const.MISSING_VAL)
    for u_t_slice, v_t_slice, circ_t_slice in zip(u, v, circ):
        print("Starting t slice")
        for u_tz_slice, v_tz_slice, circ_tz_slice in zip(
            u_t_slice, v_t_slice, circ_t_slice
        ):
            print("Starting z slice")
            integrand_u = interp.interp2(
                interpolation_x[interpolation_indexer],
                interpolation_y[interpolation_indexer],
                x[0],
                y[0],
                dx,
                dy,
                u_tz_slice,
            )
            integrand_v = interp.interp2(
                interpolation_x[interpolation_indexer],
                interpolation_y[interpolation_indexer],
                x[0],
                y[0],
                dx,
                dy,
                v_tz_slice,
            )

            ne.evaluate(
                "sum(integrand_u * ds_x + integrand_v * ds_y, 2)",
                local_dict={
                    "integrand_u": integrand_u,
                    "integrand_v": integrand_v,
                    "ds_x": ds_x,
                    "ds_y": ds_y,
                },
                out=circ_tz_slice[interpolation_indexer],
            )

    if not four_dim_u:
        circ = circ[0, ...]

    circ = np.nan_to_num(circ, nan=const.MISSING_VAL)
    return circ
