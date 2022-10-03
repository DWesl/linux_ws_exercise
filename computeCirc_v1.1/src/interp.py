# -*- coding: utf-8 -*-
"""Interpolation on regularly-spaced grids.

See Also
--------
scipy.interpolate.interpn
    Similar functionality on irregularly-spaced grids
"""
import numexpr as ne
import numpy as np
import numpy.typing as npt


def interp2(
    x: npt.NDArray[np.floating],
    y: npt.NDArray[np.floating],
    x0: float,
    y0: float,
    dx: float,
    dy: float,
    var: npt.NDArray[np.floating],
) -> npt.NDArray[np.floating]:
    """Interpolate the field from a regularly-spaced grid.

    Parameters
    ----------
    x : npt.NDArray[np.floating]
        X coordinates of points to interpolate to
    y : npt.NDArray[np.floating]
        Y coordinates of points to interpolate to
    x0 : float
        X coordinate of first data point
    y0 : float
        Y coordinate of first data point
    dx : float
        X grid spacing
    dy : float
        Y grid spacing
    var : npt.NDArray[np.floating]
        Values of variable on regularly-spaced axis-aligned grid.

    Returns
    -------
    npt.NDArray[np.floating]
        The interpolated values

    Examples
    --------
    >>> arr = np.arange(12).reshape(3, 4)
    >>> y_grid, x_grid = np.meshgrid(np.arange(3), np.arange(4), indexing="ij")
    >>> interp2(x_grid, y_grid, 0, 0, 1, 1, arr)
    array([[ 0.,  1.,  2.,  3.],
           [ 4.,  5.,  6.,  7.],
           [ 8.,  9., 10., 11.]])
    >>> interp2(x_grid[:-1, :-1] + 0.5, y_grid[:-1, :-1] + 0.5, 0, 0, 1, 1, arr)
    array([[2.5, 3.5, 4.5],
           [6.5, 7.5, 8.5]])
    """
    idx_float = ne.evaluate("(x - x0) / dx")
    left_idx = np.floor(idx_float)
    right_idx = np.ceil(idx_float).astype(int)
    x_remainder = idx_float - left_idx
    left_idx = left_idx.astype(int)

    idx_float = ne.evaluate("(y - y0) / dy")
    bottom_idx = np.floor(idx_float)
    top_idx = np.ceil(idx_float).astype(int)
    y_remainder = idx_float - bottom_idx
    bottom_idx = bottom_idx.astype(int)

    result = ne.evaluate(
        "var_bl * (1 - y_fpart) * (1 - x_fpart)"
        "+ var_br * (1 - y_fpart) * x_fpart"
        "+ var_tl * y_fpart * (1 - x_fpart)"
        "+ var_tr * y_fpart * x_fpart",
        local_dict={
            "var_bl": var[bottom_idx, left_idx],
            "var_br": var[bottom_idx, right_idx],
            "var_tl": var[top_idx, left_idx],
            "var_tr": var[top_idx, right_idx],
            "y_fpart": y_remainder,
            "x_fpart": x_remainder,
        },
    )

    return result
