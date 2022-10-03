from libc.math cimport ceil, cos, floor, sin

import numpy as np


# The next two blocks should be constants,
# but I can't figure out how to do that
# and also set their values.
cdef float MISSING_VAL = -32768.
cdef float KILOMETERS_TO_METERS = 1000.
cdef float PI = 3.14159265358979323

DEF N_AZIMUTHS = 72

def getcirc(
        float[:, :, ::1] u, float[:, :, ::1] v,
        float[::1] x, float[::1] y, float[::1] z,
        float dx, float dy, float dz,
        int nx, int ny, int nz,
        float radius
):
    cdef float[:, :, ::1] circ = np.full_like(u, MISSING_VAL)
    cdef int i, j, k
    cdef int y_space = int(ceil(radius / dy))
    cdef int x_space = int(ceil(radius / dx))
    cdef float circle_disp_x[N_AZIMUTHS]
    cdef float circle_disp_y[N_AZIMUTHS]
    cdef float ds_x[N_AZIMUTHS], ds_y[N_AZIMUTHS]
    cdef bint bad_flag
    cdef float sum_v_ds
    cdef float xtmp, ytmp, utmp, vtmp

    for i, angle in enumerate(np.linspace(0, 2 * PI, N_AZIMUTHS + 1)[:-1]):
        circle_disp_x[i] = radius * cos(angle)
        circle_disp_y[i] = radius * sin(angle)
        ds_x[i] = (
            -sin(angle) * (2 * PI * radius / N_AZIMUTHS) * KILOMETERS_TO_METERS
        )
        ds_y[i] = (
            cos(angle) * (2 * PI * radius / N_AZIMUTHS) * KILOMETERS_TO_METERS
        )

    for k in range(nz):
        for j in range(y_space, ny - y_space):
            for i in range(x_space, nx - x_space):
                bad_flag = False
                sum_v_ds = 0.

                for m in range(N_AZIMUTHS):
                    xtmp = x[i] + circle_disp_x[m]
                    ytmp = y[j] + circle_disp_y[m]
                    utmp = interp2(
                        xtmp, ytmp, x[0], y[0], dx, dy, u[k, :, :]
                    )
                    vtmp = interp2(
                        xtmp, ytmp, x[0], y[0], dx, dy, v[k, :, :]
                    )

                    if (utmp == MISSING_VAL or vtmp == MISSING_VAL):
                        bad_flag = True
                        break
                    sum_v_ds = sum_v_ds + utmp * ds_x[m] + vtmp * ds_y[m]

                if not bad_flag:
                    circ[k, j, i] = sum_v_ds
    return circ


cdef float interp2(
    float x, float y,
    float x0, float y0,
    float dx, float dy,
    float[:, ::1] var,
):
    cdef float idx_float = (x - x0) / dx
    cdef int left_idx = int(floor(idx_float))
    cdef int right_idx = int(ceil(idx_float))
    cdef float x_fpart = idx_float - left_idx

    idx_float = (y - y0) / dy
    cdef int bottom_idx = int(floor(idx_float))
    cdef int top_idx = int(ceil(idx_float))
    cdef float y_fpart = idx_float - bottom_idx

    cdef float result = (
        var[bottom_idx, left_idx] * (1 - y_fpart) * (1 - x_fpart)
        + var[bottom_idx, right_idx] * (1 - y_fpart) * x_fpart
        + var[top_idx, left_idx] * y_fpart * (1 - x_fpart)
        + var[top_idx, right_idx] * y_fpart * x_fpart
    )
    return result
