      module interp
      implicit none
      private
      public :: interp3
      contains
      subroutine interp3(x,y,z,xgrid,ygrid,zgrid,dx,dy,dz,
     >                  var,nx,ny,nz,interpvar)

      implicit none

      include '../include/const.h'

      integer, intent(in) :: nx, ny, nz      ! dimensions of gridded dataset
      real, intent(in) :: var(nx,ny,nz)      ! gridded dataset
      real, intent(in) :: xgrid(nx), ygrid(ny), zgrid(nz)    ! x, y, z coordinates of grid points
      real, intent(in) :: dx, dy, dz         ! grid spacing (assumed uniform!)
      real, intent(in) :: x, y, z            ! coordinates of location
                                             ! to which var will be
                                             ! interpolated
      integer i, j, k         ! indices
      integer sx, sy, sz      ! indices of gridpoint located immediately southwest and below (x,y,z)
      real c1, c2, c3         ! factors used in space interpolation
      real, intent(out) :: interpvar          ! value of var interpolated to position x,y,z


! Find indices of gridpt located to the immediate southwest and below the parcel...

      sx = int((x-xgrid(1))/dx) + 1
      sy = int((y-ygrid(1))/dy) + 1
      sz = int((z-zgrid(1))/dz) + 1

! Interpolate in space...
     
      c1 = (x-xgrid(sx)) / dx                       
      c2 = (y-ygrid(sy)) / dy                       
      c3 = (z-zgrid(sz)) / dz                    
                                                   
      if ( var(sx,sy,sz).ne.missing_val .and.
     >     var(sx+1,sy,sz).ne.missing_val .and.
     >     var(sx,sy+1,sz).ne.missing_val .and.
     >     var(sx,sy,sz+1).ne.missing_val .and.
     >     var(sx+1,sy,sz+1).ne.missing_val .and.
     >     var(sx,sy+1,sz+1).ne.missing_val .and.
     >     var(sx+1,sy+1,sz).ne.missing_val .and.
     >     var(sx+1,sy+1,sz+1).ne.missing_val ) then

         interpvar = (1-c1)*(1-c2)*(1-c3)*var(sx,sy,sz)
     >              + c1*(1-c2)*(1-c3)*var(sx+1,sy,sz)
     >              + (1-c1)*c2*(1-c3)*var(sx,sy+1,sz)
     >              + (1-c1)*(1-c2)*c3*var(sx,sy,sz+1)
     >              + c1*(1-c2)*c3*var(sx+1,sy,sz+1)
     >              + (1-c1)*c2*c3*var(sx,sy+1,sz+1)
     >              + c1*c2*(1-c3)*var(sx+1,sy+1,sz)
     >              + c1*c2*c3*var(sx+1,sy+1,sz+1)

      else 
         
         interpvar = missing_val

      endif

      return
      end
      end module interp
