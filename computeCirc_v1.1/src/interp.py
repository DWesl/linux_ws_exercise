"""Interpolation on regularly-spaced grids.

See Also
--------
scipy.interpolate.interpn
    Similar functionality on irregularly-spaced grids
"""

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

    """
    idx_float = (x - x0) / dx
    left_idx = np.floor(idx_float)
    right_idx = np.ceil(idx_float).astype(int)
    x_remainder = idx_float - left_idx
    left_idx = left_idx.astype(int)

    idx_float = (y - y0) / dy
    bottom_idx = np.floor(idx_float)
    top_idx = np.ceil(idx_float).astype(int)
    y_remainder = idx_float - bottom_idx
    bottom_idx = bottom_idx.astype(int)

    result = (
        var[bottom_idx, left_idx] * (1 - y_remainder) * (1 - x_remainder)
        + var[bottom_idx, right_idx] * (1 - y_remainder) * x_remainder
        + var[top_idx, left_idx] * y_remainder * (1 - x_remainder)
        + var[top_idx, right_idx] * y_remainder * x_remainder
    )
    return result
