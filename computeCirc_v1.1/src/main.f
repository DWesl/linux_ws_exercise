! Compile with pgf90


      program computeC

      implicit none

      include '../include/const.h'
	
      integer i, j, k, n, nx, ny, nz, nv
      integer nfiles, istatus

      real, allocatable :: x(:)
      real, allocatable :: y(:)
      real, allocatable :: z(:)
      real, allocatable :: u(:,:,:)
      real, allocatable :: v(:,:,:)
      real, allocatable :: circ(:,:,:)

      real dx, dy, dz

      character*100 infile(maxfiles)
      character*8 label
      character*8 u_variable, v_variable
      real Cscale, radius

      namelist /inputparms/ nfiles, infile, u_variable,
     >                      v_variable, radius

!-----------------------------------------------------------------      
! Scale factors

      Cscale = 1.e-4

!-----------------------------------------------------------------      
! Obtain input parameters

      read(5, inputparms)

!-----------------------------------------------------------------
! Begin main program loop

      do n = 1, nfiles

! Determine size of arrays and get data from netcdf file.

        print*,'Computing circulation...'

        call getsize(infile(n),nx,ny,nz,nv)
        allocate (x(nx),y(ny),z(nz))
        call getgridinfo(infile(n),dx,dy,dz,x,y,z,nx,ny,nz)

        allocate ( u(nx,ny,nz), v(nx,ny,nz), circ(nx,ny,nz) ) 

        call netcdf_read(u,u_variable,infile(n),nx,ny,nz)
        call netcdf_read(v,v_variable,infile(n),nx,ny,nz)

        call getcirc(u,v,x,y,z,dx,dy,dz,nx,ny,nz,radius,circ)

        do i = 1, nx
        do j = 1, ny
        do k = 1, nz

           if ( circ(i,j,k) .ne. missing_val ) then
             circ(i,j,k) = circ(i,j,k)*Cscale
           endif

        enddo
        enddo 
        enddo


        print*,'Done.'
        print*, ' '
        print*,'Writing data to netcdf file...'

        label = 'CIRC    '
        call varinq(label,infile(n),istatus)
        if ( istatus .eq. 0 ) then
           call netcdf_write(circ,label,infile(n),nx,ny,nz)
        else
           call netcdf_overwrite(circ,label,infile(n),nx,ny,nz)
        endif

        print*,'Done.'
        print*, ' '
        print*,'Operation completed for ', infile(n)
        print*, ' ' 
        print*, ' '

! End of main program loop

        deallocate (u,v,circ,x,y,z)

      enddo      

!------------------------------------------------------------------

      end


!    END OF MAIN CODE
!------------------------------------------------------------------


      
 
