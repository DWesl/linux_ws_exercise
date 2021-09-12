!--------------------------------------------------------------------
! This subroutine computes circulation.


      subroutine getcirc(u,v,x,y,z,dx,dy,dz,nx,ny,nz,radius,circ)

      implicit none

      include '../include/const.h'

! Passed variables

      integer nx, ny, nz
      real radius, dx, dy, dz
      real x(nx), y(ny), z(nz)
      real u(nx,ny,nz), v(nx,ny,nz)
      real circ(nx,ny,nz)

! Local variables
 
      integer i, j, k, m
      real utmp, vtmp, angle, metangle, sumVt, incr
      real xtmp, ytmp
      integer nazimuths, badflag
      parameter (nazimuths = 72)

!--------------------------------------------------------------------      

      circ(:,:,:) = missing_val

      do k = 1, nz-1  ! only go to nx-1, ny-1, nz-1 to prevent seg faults
                      ! because of how interp is handled in interp.f (need
        do i = 1, nx-1   ! values at grid indices sx+1, sy+1, sz+1 for gridpoints
        do j = 1, ny-1   ! at locations sx, sy, sz

         badflag = 0
         sumVt = 0.
         incr = 360./nazimuths

         do m = 1, nazimuths
           angle = incr*m
           metangle = 90. - angle
           if (metangle .lt. 0) metangle = metangle + 360.
           angle = angle*pi/180.
           metangle = metangle*pi/180.
           xtmp = x(i) + radius*sin(angle)
           ytmp = y(j) + radius*cos(angle)
           call interp(xtmp,ytmp,z(k),x,y,z,dx,dy,dz,u,nx,ny,nz,utmp)
           call interp(xtmp,ytmp,z(k),x,y,z,dx,dy,dz,v,nx,ny,nz,vtmp)
           if (utmp.eq.missing_val .or. vtmp.eq.missing_val) then
             badflag = 1
             exit
           else
             sumVt = sumVt - utmp*sin(metangle)
     >                     + vtmp*cos(metangle)
           endif
         enddo
        
         if (badflag.ne.1) then
           circ(i,j,k) = (sumVt/nazimuths)*2.*pi*radius*km2m
         endif

        enddo
        enddo
 
      enddo

      return
      end


