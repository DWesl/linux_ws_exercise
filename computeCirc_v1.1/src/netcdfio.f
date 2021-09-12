!----------------------------------------------------------------------
! This subroutine returns nx, ny, nz, and nv from a netcdf file

      subroutine getsize(filename,nx,ny,nz,nv)

      implicit none

      include '../../netcdf/include/netcdf.inc'

! Passed variables

      integer nx, ny, nz        ! number of x, y, and z grid points

      integer nv                ! number of variables

      character filename*100    ! netcdf filename

! Local variables

      integer ncid                    ! File id for the NetCDF file

      integer rcode                   ! Return code for calls to NetCDF library
 
      integer itmp                    ! temporary integer value
      
      character tmpstring*(MAXNCNAM)  ! temporary character string

!----------------------------------------------------------------------
! Open netcdf file.
    
      ncid = ncopn(filename, NCNOWRIT, rcode)
      
! Obtain nx, ny, nz, nv from netcdf file.

      itmp = ncdid(ncid,'x',rcode)
      call ncdinq(ncid,itmp,tmpstring,nx,rcode)
      itmp = ncdid(ncid,'y',rcode)
      call ncdinq(ncid,itmp,tmpstring,ny,rcode)
      itmp = ncdid(ncid,'z',rcode)
      call ncdinq(ncid,itmp,tmpstring,nz,rcode)
      itmp = ncdid(ncid,'fields',rcode)
      call ncdinq(ncid,itmp,tmpstring,nv,rcode)

! Close netcdf file.

      call ncclos(ncid, rcode)

      return
      end

!----------------------------------------------------------------------





!----------------------------------------------------------------------
! This subroutine returns dx, dy, dz, and x, y, z coordinates
! from a netcdf file

      subroutine getgridinfo(filename,dx,dy,dz,x,y,z,nx,ny,nz)

      implicit none

      include '../../netcdf/include/netcdf.inc'

! Passed variables

      integer nx, ny, nz        ! number of x, y, and z grid points

      real dx, dy, dz           ! x, y, z grid spacing
 
      real x(nx), y(ny), z(nz)  ! x, y, z grid point coordinates

      character filename*100    ! netcdf filename

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

      include '../../netcdf/include/netcdf.inc'

! Passed variables

      integer nv                      ! number of variables

      character filename*100          ! netcdf filename
 
      character varname(nv)*8         ! variable name

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

      include '../../netcdf/include/netcdf.inc'

! Passed variables

      integer nx, ny, nz        ! number of x, y, and z grid points

      character filename*100    ! netcdf filename
 
      character varname*8       ! variable name for which data are requested
 
      real val(nx,ny,nz)        ! value of variable requested

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

      include '../../netcdf/include/netcdf.inc'

! Passed variables            

      integer nx, ny, nz      ! number of x, y, and z grid points
      
      character filename*100  ! netcdf filename
 
      real val(nx,ny,nz)      ! value of variable to be written

      character varname*8     ! name of variable to be written

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

      include '../../netcdf/include/netcdf.inc'

! Passed variables

      integer nx, ny, nz      ! number of x, y, and z grid points

      character filename*100  ! netcdf filename

      real val(nx,ny,nz)      ! value of variable to be written

      character varname*8     ! name of variable to be written

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

      include '../../netcdf/include/netcdf.inc'

! Passed variables

      integer rstatus           ! 0 if varname is not present in filename
                                ! 1 if varname is present in filename

      character filename*100    ! netcdf filename

      character varname*8       ! variable name

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
