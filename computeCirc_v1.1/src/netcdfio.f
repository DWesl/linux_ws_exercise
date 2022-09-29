      module netcdfio
      use netcdf
      implicit none
      private
      public :: getsize, getgridinfo
      public :: getvarnames, varinq
      public :: netcdf_read, netcdf_overwrite, netcdf_write
      contains
!----------------------------------------------------------------------
! This subroutine returns nx, ny, nz, and nv from a netcdf file

      subroutine getsize(filename,nx,ny,nz,nv)

      implicit none

      include 'netcdf.inc'

! Passed variables

      integer, intent(out) :: nx, ny, nz        ! number of x, y, and z grid points

      integer, intent(out) :: nv                ! number of variables

      character(len=100), intent(in) :: filename    ! netcdf filename

! Local variables

      integer ncid                    ! File id for the NetCDF file

      integer rcode                   ! Return code for calls to NetCDF library
 
      integer itmp                    ! temporary integer value
      
      character(len=MAXNCNAM) tmpstring  ! temporary character string

!----------------------------------------------------------------------
! Open netcdf file.

      print*,'Opening file'
c$$$  ncid = ncopn(filename, NCNOWRIT, rcode)
      rcode = nf90_open(filename, NF90_NOWRITE, ncid)
      print*,rcode
      if (rcode .ne. NF90_NOERR) then
         print *, 'Failed to open file; does it exist?'
      endif
! Obtain nx, ny, nz, nv from netcdf file.

      print*,'Getting dimension sizes'
c$$$      itmp = ncdid(ncid,'x',rcode)
      rcode = nf90_inq_dimid(ncid, 'x', itmp)
      if (rcode .ne. NF90_NOERR) then
         print *, 'Failed to find x dimension'
      endif
c$$$      call ncdinq(ncid,itmp,tmpstring,nx,rcode)
c$$$  print*,rcode
      rcode = nf90_inquire_dimension(ncid, itmp, tmpstring, nx)
      if (rcode .ne. NF90_NOERR) then
         print *, 'Failed to find length of x dimension'
      endif
c$$$      itmp = ncdid(ncid,'y',rcode)
c$$$      call ncdinq(ncid,itmp,tmpstring,ny,rcode)
c$$$      print*,rcode
      rcode = nf90_inq_dimid(ncid, 'y', itmp)
      if (rcode .ne. NF90_NOERR) then
         print *, 'Failed to find y dimension'
      endif
      rcode = nf90_inquire_dimension(ncid, itmp, tmpstring, ny)
      if (rcode .ne. NF90_NOERR) then
         print *, 'Failed to find length of y dimension'
      endif
c$$$      itmp = ncdid(ncid,'z',rcode)
c$$$      call ncdinq(ncid,itmp,tmpstring,nz,rcode)
c$$$      print*,rcode
      rcode = nf90_inq_dimid(ncid, 'z', itmp)
      if (rcode .ne. NF90_NOERR) then
         print *, 'Failed to find z dimension'
      endif
      rcode = nf90_inquire_dimension(ncid, itmp, tmpstring, nz)
      if (rcode .ne. NF90_NOERR) then
         print *, 'Failed to find length of z dimension'
      endif

c$$$      itmp = ncdid(ncid,'fields',rcode)
c$$$      call ncdinq(ncid,itmp,tmpstring,nv,rcode)
c$$$      print*,rcode
      rcode = nf90_inq_dimid(ncid, 'fields', itmp)
      if (rcode .ne. NF90_NOERR) then
         print *, 'Failed to find fields dimension'
      endif
      rcode = nf90_inquire_dimension(ncid, itmp, tmpstring, nv)
      if (rcode .ne. NF90_NOERR) then
         print *, 'Failed to find length of fields dimension'
      endif

! Close netcdf file.

c$$$  call ncclos(ncid, rcode)
      rcode = nf90_close(ncid)
      if (rcode .ne. NF90_NOERR) then
         print *, 'Failed to close file'
      endif

      return
      end

!----------------------------------------------------------------------





!----------------------------------------------------------------------
! This subroutine returns dx, dy, dz, and x, y, z coordinates
! from a netcdf file

      subroutine getgridinfo(filename,dx,dy,dz,x,y,z,nx,ny,nz)

      implicit none

      include 'netcdf.inc'

! Passed variables

      integer, intent(in) :: nx, ny, nz        ! number of x, y, and z grid points

      real, intent(out) :: dx, dy, dz           ! x, y, z grid spacing
 
      real, intent(out) :: x(nx), y(ny), z(nz)  ! x, y, z grid point coordinates

      character(len=100), intent(in) :: filename    ! netcdf filename

! Local variables

      integer ncid              ! File id for the NetCDF file

      integer rcode             ! Return code for calls to NetCDF library
 
      integer i, j, k           ! indices
      
      integer itmp              ! temporary integer

!----------------------------------------------------------------------
! Open netcdf file.
    
      ncid = ncopn(filename, NCNOWRIT, rcode)
      
! Obtain dx, dy, dz, and x, y, z coordinates    
  
      itmp = ncvid(ncid,'x',rcode)
      do i = 1, nx
         call ncvgt1(ncid,itmp,i,x(i),rcode)
      enddo


      itmp = ncvid(ncid,'y',rcode)
      do j = 1, ny
         call ncvgt1(ncid,itmp,j,y(j),rcode)
      enddo

      itmp = ncvid(ncid,'z',rcode)
      do k = 1, nz
         call ncvgt1(ncid,itmp,k,z(k),rcode)
      enddo

      itmp = ncvid(ncid,'x_spacing',rcode)
      call ncvgt1(ncid,itmp,1,dx,rcode)
      itmp = ncvid(ncid,'y_spacing',rcode)
      call ncvgt1(ncid,itmp,1,dy,rcode)
      itmp = ncvid(ncid,'z_spacing',rcode)
      call ncvgt1(ncid,itmp,1,dz,rcode)

! Close netcdf file.

      call ncclos(ncid, rcode)

      return
      end

!----------------------------------------------------------------------

!----------------------------------------------------------------------
! This subroutine returns a list of the variables contained in a 
! netcdf file

      subroutine getvarnames(filename,varname,nv)

      implicit none

      include 'netcdf.inc'

! Passed variables

      integer, intent(in) :: nv                      ! number of variables

      character(len=100), intent(in) :: filename     ! netcdf filename
 
      character(len=8), dimension(nv), intent(out) :: varname  ! variable name

! Local variables

      integer ncid                    ! File id for the NetCDF file

      integer rcode                   ! Return code for calls to NetCDF library
      
      character ctmp1*1, ctmp8*8      ! temporary character string

      integer ncindex2(2)             ! temporary index value

      integer i, j                    ! indices

      integer itmp

!----------------------------------------------------------------------
! Open netcdf file.
    
      ncid = ncopn (filename, NCNOWRIT, rcode)
      
! Obtain variable names from netcdf file.

      itmp = ncvid(ncid,'field_names',rcode)

      do j = 1, nv
      do i = 1, 8
         ncindex2(1) = i
         ncindex2(2) = j
         call ncvg1c(ncid,itmp,ncindex2,ctmp1,rcode)
         write(ctmp8(i:i),100) ctmp1
      enddo
         varname(j) = ctmp8
      enddo

 100  format(a1)


! Close netcdf file.

      call ncclos(ncid, rcode)

      return
      end

!----------------------------------------------------------------------


!----------------------------------------------------------------------
! This subroutine extracts data from a netcdf file.


      subroutine netcdf_read(val,varname,filename,nx,ny,nz)

      implicit none

      include 'netcdf.inc'

! Passed variables

      integer, intent(in) :: nx, ny, nz        ! number of x, y, and z grid points

      character(len=100), intent(in) :: filename ! netcdf filename
 
      character(len=8), intent(in) :: varname    ! variable name for which data are requested
 
      real, intent(out), dimension(nx, ny, nz) :: val  ! value of variable requested

! Local variables

      integer ncid                    ! file id for the NetCDF file

      integer rcode                   ! return code for calls to NetCDF library
      
      integer ncindex1(4)             ! temporary index value

      integer ncindex2(4)             ! temporary index value

      integer i, j, k                 ! indices

      integer varid                   ! variable ID


!----------------------------------------------------------------------
! Open netcdf file.
    
      ncid = ncopn (filename, NCNOWRIT, rcode)
      
! Determine ID of variable in the netcdf file.

      varid = ncvid(ncid, varname, rcode)

! Get data.      

      ncindex1(1) = 1
      ncindex1(2) = 1
      ncindex1(3) = 1
      ncindex1(4) = 1

      ncindex2(1) = nx
      ncindex2(2) = ny
      ncindex2(3) = nz
      ncindex2(4) = 1

      call ncvgt(ncid,varid,ncindex1,ncindex2,val,rcode)

! Close netcdf file.

      call ncclos(ncid, rcode)

      return
      end

!----------------------------------------------------------------------



!----------------------------------------------------------------------
! This subroutine overwrites a 3D array of data in a netcdf file. 

      subroutine netcdf_overwrite(val,varname,filename,nx,ny,nz)

      implicit none

      include 'netcdf.inc'

! Passed variables            

      integer, intent(in) :: nx, ny, nz      ! number of x, y, and z grid points
      
      character(len=100), intent(in) :: filename  ! netcdf filename
 
      real, dimension(nx, ny, nz), intent(in) :: val  ! value of variable to be written

      character(len=8), intent(in) :: varname     ! name of variable to be written

! Local variables

      integer ncid            ! file id for the NetCDF file

      integer rcode           ! return code for calls to NetCDF library

      integer i, j, k         ! indices

      integer ncindex1(4)     ! temporary index values

      integer ncindex2(4)     ! temporary index values

      integer varid           ! variable ID


!----------------------------------------------------------------------
! Open netcdf file.

      ncid = ncopn(filename, NCWRITE, rcode)

! Determine ID of variable in the netcdf file.

      varid = ncvid(ncid, varname, rcode)

! Write data.

      ncindex1(1) = 1
      ncindex1(2) = 1
      ncindex1(3) = 1
      ncindex1(4) = 1

      ncindex2(1) = nx
      ncindex2(2) = ny
      ncindex2(3) = nz
      ncindex2(4) = 1

      call ncvpt(ncid,varid,ncindex1,ncindex2,val,rcode)

! Close netcdf file.

      call ncclos(ncid,rcode)

      return
      end

!---------------------------------------------------------------------



!---------------------------------------------------------------------
! This subroutine writes a *new* 3D array of data in a netcdf file.  
! If the 3D array already exists in the netcdf file, then 
! subroutine netcdf_overwrite should be called.

      subroutine netcdf_write(val,varname,filename,nx,ny,nz)

      implicit none

      include 'netcdf.inc'

! Passed variables

      integer, intent(in) :: nx, ny, nz      ! number of x, y, and z grid points

      character(len=100), intent(in) :: filename  ! netcdf filename

      real, dimension(nx, ny, nz), intent(in) :: val  ! value of variable to be written

      character(len=8), intent(in) :: varname     ! name of variable to be written

! Local variables

      integer ncid            ! file id for the NetCDF file

      integer rcode           ! return code for calls to NetCDF library

      integer i, j, k         ! indices

      integer ncindex1(4)     ! temporary index values

      integer ncindex2(4)     ! temporary index values

      integer varid           ! variable ID

      integer vartyp          ! type of netcdf variable

      integer nvdims          ! number of variable dimensions
 
      integer vdims(maxvdims) ! variable dimensions

      integer nvatts          ! number of variable attributes

      integer nvars           ! number of variables in netcdf file

      integer attype          ! type of attribute

      integer attlen          ! length of attribute

      integer ndims           ! number of dimensions
 
      integer natts           ! number of attributes

      integer recdim          ! dimension of record

      character attnam*(maxncnam)  ! attribute character string

      real, allocatable::value1(:) ! array of attribute info

      character string*(maxncnam)  ! temporary character string

      character varnam*(maxncnam)  ! name of last variable appearing in
                                   ! original netcdf file

!----------------------------------------------------------------------
! Open netcdf file.

      ncid = ncopn(filename, NCWRITE, rcode)

! Create space for new field in existing netcdf file.

      call ncinq(ncid,ndims,nvars,natts,recdim,rcode)

      call ncredf(ncid,rcode)
 
      call ncvinq(ncid,nvars,varnam,vartyp,nvdims,vdims,nvatts,rcode)
      varid = ncvdef(ncid,varname,vartyp,nvdims,vdims,rcode)
      do j = 1, nvatts
         call ncanam(ncid,nvars,j,attnam,rcode)
         call ncainq(ncid,nvars,attnam,attype,attlen,rcode)
         if (attype .ne. 2 ) then
            allocate (value1(attlen))
            call ncagt(ncid,nvars,attnam,value1,rcode)
            call ncapt(ncid,nvars+1,attnam,attype,attlen,value1,rcode)
            deallocate (value1)
         else
            call ncagtc(ncid,nvars,attnam,string,attlen,
     >                  rcode)
            call ncaptc(ncid,nvars+1,attnam,attype,attlen,
     >                  string,rcode)
         endif
      enddo

      call ncendf(ncid,rcode)

! Write data.

      ncindex1(1) = 1
      ncindex1(2) = 1
      ncindex1(3) = 1
      ncindex1(4) = 1

      ncindex2(1) = nx
      ncindex2(2) = ny
      ncindex2(3) = nz
      ncindex2(4) = 1

      call ncvpt(ncid,varid,ncindex1,ncindex2,val,rcode)

! Close netcdf file.

      call ncclos(ncid,rcode)

      return
      end

!---------------------------------------------------------------------



!----------------------------------------------------------------------
! This subroutine finds out if a variable already exists in given
! netcdf file.  A "1" is returned if a variable already exists,
! otherwise, a "0" is returned.


      subroutine varinq(varname,filename,rstatus)

      implicit none

      include 'netcdf.inc'

! Passed variables

      integer, intent(out) :: rstatus  ! 0 if varname is not present in filename
                                       ! 1 if varname is present in filename

      character(len=100), intent(in) :: filename  ! netcdf filename

      character(len=8), intent(in) :: varname     ! variable name

! Local variables

      integer ncid              ! File id for the NetCDF file

      integer rcode             ! Return code for calls to NetCDF library

      integer i                 ! index

      integer vartyp            ! type of variable

      integer nvdims            ! number of variable dimensions

      integer nvatts            ! number of variable attributes

      integer vdims(maxvdims)   ! variable dimensions

      character tmpvar*8        ! temporary string

      integer ndims             ! number of netcdf dimensions

      integer nvars             ! number of netcdf variables

      integer natts             ! number of attributes

      integer recdim            ! record dimension

      integer itmp              ! temporary integer

!----------------------------------------------------------------------
! Open netcdf file.

      ncid = ncopn (filename, NCNOWRIT, rcode)

! Obtain variable names from netcdf file.

      call ncinq(ncid,ndims,nvars,natts,recdim,rcode)

      rstatus = 0
      itmp = ncvid(ncid,'field_names',rcode)

      do i = itmp+1, nvars
         call ncvinq(ncid,i,tmpvar,vartyp,nvdims,vdims,nvatts,rcode)
         if (tmpvar .eq. varname) rstatus = 1
      enddo

! Close netcdf file.

      call ncclos(ncid, rcode)

      return
      end

      end module netcdfio
