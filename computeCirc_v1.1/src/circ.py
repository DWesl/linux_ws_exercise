import math

import numpy as np

import const
import interp

N_AZIMUTHS = 72

def getcirc(
        u: "np.ndarray[(nz, ny, nx), np.floating]",
        v: "np.ndarray[(nz, ny, nx), np.floating]",
        x: "np.ndarray[(nx,), np.floating]",
        y: "np.ndarray[(ny,), np.floating]",
        z: "np.ndarray[(nz,), np.floating]",
        dx: float, dy: float, dz: float,
        nx: int, ny: int, nz: int,
        radius: float
) -> "np.ndarray[(nz, ny, nx), np.floating]":
    circ = np.full_like(u, const.MISSING_VAL)
    z_space = math.ceil(radius / dz)
    y_space = math.ceil(radius / dy)
    x_space = math.ceil(radius / dx)
    for k in range(nz - 1):
        for j in range(y_space, ny - y_space):
            for i in range(x_space, nx - x_space):
                badflag = False
                sumVt = 0.
                angles = np.linspace(0, 2 * const.PI, N_AZIMUTHS + 1)[:-1]
                xtmps = x[i] + radius * np.cos(angles)
                ytmps = y[j] + radius * np.sin(angles)
                tangents_x = -np.sin(angles)
                tangents_y = np.cos(angles)
                for xtmp, ytmp, tan_x, tan_y in zip(xtmps, ytmps, tangents_x, tangents_y):
                    utmp = interp.interp(xtmp, ytmp, z[k], x, y, z, dx, dy, dz, u, nx, ny, nz)
                    vtmp = interp.interp(xtmp, ytmp, z[k], x, y, z, dx, dy, dz, v, nx, ny, nz)
                    if utmp == const.MISSING_VAL or vtmp = const.MISSING_VAL:
                        badflag = True
                        break
                    sumVt = sumVt + utmp * tan_x + vtmp * tan_y
                else:
                    circ[k, j, i] = sumVt * (2 * const.PI * radius / N_AZIMUTHS) * const.KM2M
    return circ
