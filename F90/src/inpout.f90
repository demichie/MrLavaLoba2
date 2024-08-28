!********************************************************************************
!> \brief Input/Output module
!
!> This module contains all the input/output subroutine and the 
!> realted variables.
!
!> \date 2024/08/20
!> \author Mattia de' Michieli Vitturi
!> \author Simone Tarquini
!
!********************************************************************************

MODULE inpout

  USE parameters

  IMPLICIT NONE

  CHARACTER(LEN=40) :: input_file         !< File with the run parameters
  CHARACTER(LEN=40) :: backup_file        !< Bakcup File with the run parameters
  INTEGER, PARAMETER :: input_unit = 7       !< Input data unit
  INTEGER, PARAMETER :: topo_unit = 8        !< Topography DEM unit
  INTEGER, PARAMETER :: backup_unit = 9      !> Input Backup data unit
  INTEGER, PARAMETER :: restart_unit = 10
  INTEGER, PARAMETER :: output_unit = 11

  INTEGER :: cols, rows
  
  NAMELIST / run_parameters / run_name, source, vent_flag, crop_flag,           &
       hazard_flag, volume_flag, fixed_dimension_flag, topo_mod_flag,           &
       restart_flag

  NAMELIST / vent_parameters / n_vents, x_vent, y_vent

  NAMELIST / crop_parameters / east_to_vent, west_to_vent, south_to_vent,       &
       north_to_vent
  
  NAMELIST / flow_parameters / n_flows, min_n_lobes, max_n_lobes, total_volume, &
       lobe_area, avg_lobe_thickness, thickness_ratio , thickening_parameter,   &
       lobe_exponent, max_slope_prob, inertial_exponent , n_init , dist_fact,   &
       aspect_ratio_coeff, max_aspect_ratio, a_beta, b_beta

  NAMELIST / restart_parameters / n_restarts, restart_files,                    &
       restart_filling_parameters

  NAMELIST / numerical_parameters / npoints, nv

       
CONTAINS

  !******************************************************************************
  !> \brief Initialization of the variables read from the input file
  !
  !> This subroutine initialize the input variables with default values.
  !
  !> @author 
  !> Mattia de' Michieli Vitturi
  !> \date 2024/08/20
  !
  !******************************************************************************

  SUBROUTINE init_param  

    IMPLICIT none

    vent_flag = -1

    n_vents = -9999
    ALLOCATE(x_vent(20))
    ALLOCATE(y_vent(20))
    x_vent(:) = -9999.0_wp
    y_vent(:) = -9999.0_wp

    east_to_vent = -9999.0_wp
    west_to_vent = -9999.0_wp
    south_to_vent = -9999.0_wp
    north_to_vent = -9999.0_wp

    n_flows = -9999
    min_n_lobes = -9999
    max_n_lobes = -9999
    total_volume = -9999.0_wp
    lobe_area = -9999.0_wp
    avg_lobe_thickness = -9999.0_wp
    thickness_ratio = -9999.0_wp
    thickening_parameter = -9999.0_wp
    lobe_exponent = -9999.0_wp
    max_slope_prob = -9999.0_wp
    inertial_exponent = -9999.0_wp
    n_init = -9999
    dist_fact = -9999.0_wp
    aspect_ratio_coeff = -9999.0_wp
    max_aspect_ratio = -9999.0_wp
    npoints = -9999

    a_beta = -9999.0_wp
    b_beta = -9999.0_wp

    n_restarts = -9999
    ALLOCATE(restart_files(20))
    ALLOCATE(restart_filling_parameters(20))

    force_max_length = .FALSE.
    start_from_dist_flag = .FALSE.
    max_length = 50
    
    
  END SUBROUTINE init_param

  SUBROUTINE read_param
    
    IMPLICIT NONE
    
    INTEGER :: ios
    LOGICAL :: lexist
    LOGICAL :: condition

    CHARACTER(LEN=40) :: base_name

    REAL(wp), ALLOCATABLE :: x_vent_temp(:)
    REAL(wp), ALLOCATABLE :: y_vent_temp(:)

    CHARACTER(LEN = 40), ALLOCATABLE :: restart_files_temp(:)
    REAL(wp), ALLOCATABLE :: restart_filling_parameters_temp(:)
    
    INTEGER :: i    !< loop counter
    
    LOGICAL :: tend1 
    CHARACTER(LEN=80) :: card
    
    input_file = 'mr_lava_loba.inp'
    
    INQUIRE (FILE=input_file,exist=lexist)
    
    IF (lexist .EQV. .FALSE.) THEN
       
       WRITE(*,*) 'Input file IMEX_SfloW2D.inp not found'
       STOP
       
    END IF
    
    OPEN(input_unit,FILE=input_file,STATUS='old')
    
    ! ---------- READ run_parameters NAMELIST -----------------------------------
    READ(input_unit, run_parameters,IOSTAT=ios )
    
    IF ( ios .NE. 0 ) THEN
       
       WRITE(*,*) 'IOSTAT=',ios
       WRITE(*,*) 'ERROR: problem with namelist RUN_PARAMETERS'
       WRITE(*,*) 'Please check the input file'
       WRITE(*,run_parameters)
       STOP
       
    ELSE
       
       WRITE(*,*) 'Run name: ',run_name
       REWIND(input_unit)
       
    END IF

    ! ---------- READ vent_parameters NAMELIST -----------------------------------
    READ(input_unit, vent_parameters,IOSTAT=ios )
    
    IF ( ios .NE. 0 ) THEN
       
       WRITE(*,*) 'IOSTAT=',ios
       WRITE(*,*) 'ERROR: problem with namelist VENT_PARAMETERS'
       WRITE(*,*) 'Please check the input file'
       WRITE(*,vent_parameters)
       STOP
       
    ELSE

       ALLOCATE(x_vent_temp(n_vents))
       ALLOCATE(y_vent_temp(n_vents))

       x_vent_temp(1:n_vents) = x_vent(1:n_vents)
       y_vent_temp(1:n_vents) = y_vent(1:n_vents)
       
       DEALLOCATE(x_vent)
       DEALLOCATE(y_vent)
       
       ALLOCATE(x_vent(n_vents))
       ALLOCATE(y_vent(n_vents))

       x_vent(:) = x_vent_temp(:)
       y_vent(:) = y_vent_temp(:)
       
       DEALLOCATE(x_vent_temp)
       DEALLOCATE(y_vent_temp)

       WRITE(*,*) 'x_vent ',x_vent 
       WRITE(*,*) 'y_vent ',y_vent 
              
       REWIND(input_unit)
       
    END IF

    IF ( crop_flag ) THEN
       
       ! ---------- READ crop_parameters NAMELIST -----------------------------------
       READ(input_unit, crop_parameters,IOSTAT=ios )
       
       IF ( ios .NE. 0 ) THEN
          
          WRITE(*,*) 'IOSTAT=',ios
          WRITE(*,*) 'ERROR: problem with namelist CROP_PARAMETERS'
          WRITE(*,*) 'Please check the input file'
          WRITE(*,crop_parameters)
          STOP
          
       ELSE
          
          REWIND(input_unit)
          
       END IF

    END IF
       
    ! ---------- READ flow_parameters NAMELIST -----------------------------------
    READ(input_unit, flow_parameters,IOSTAT=ios )
    
    IF ( ios .NE. 0 ) THEN
       
       WRITE(*,*) 'IOSTAT=',ios
       WRITE(*,*) 'ERROR: problem with namelist FLOW_PARAMETERS'
       WRITE(*,*) 'Please check the input file'
       WRITE(*,flow_parameters)
       STOP
       
    ELSE

       IF ( max_n_lobes .EQ. -9999 ) THEN

          max_n_lobes = min_n_lobes

       END IF

       ! Check if volume_flag is set
       if (volume_flag) then
          
          ! Fixed dimension flag logic
          if (fixed_dimension_flag ) then
             avg_lobe_thickness = total_volume / (n_flows * lobe_area * 0.5     &
                  * (min_n_lobes + max_n_lobes))
             print *, "Average Lobe thickness = ", avg_lobe_thickness, " m"
             
          else
             lobe_area = total_volume / (n_flows * avg_lobe_thickness * 0.5     &
                  * (min_n_lobes + max_n_lobes))
             print *, "Lobe area = ", lobe_area, " m2"
             
          end if
          
       end if
       
       REWIND(input_unit)
       
    END IF

    IF ( restart_flag) THEN
       
       ! ---------- READ restart_parameters NAMELIST -----------------------------------
       READ(input_unit, restart_parameters,IOSTAT=ios )
       
       IF ( ios .NE. 0 ) THEN
          
          WRITE(*,*) 'IOSTAT=',ios
          WRITE(*,*) 'ERROR: problem with namelist RESTART_PARAMETERS'
          WRITE(*,*) 'Please check the input file'
          WRITE(*,restart_parameters)
          STOP
          
       ELSE

       ALLOCATE(restart_files_temp(n_restarts))
       ALLOCATE(restart_filling_parameters_temp(n_restarts))

       restart_files_temp(1:n_restarts) = restart_files(1:n_restarts)
       restart_filling_parameters_temp(1:n_restarts) = restart_filling_parameters(1:n_restarts)
       
       DEALLOCATE(restart_files)
       DEALLOCATE(restart_filling_parameters)
       
       ALLOCATE(restart_files(n_restarts))
       ALLOCATE(restart_filling_parameters(n_restarts))

       restart_files(:) = restart_files_temp(:)
       restart_filling_parameters(:) = restart_filling_parameters_temp(:)
       
       DEALLOCATE(restart_files_temp)
       DEALLOCATE(restart_filling_parameters_temp)

       WRITE(*,*) 'restart_files ',restart_files 
                 
          REWIND(input_unit)
          
       END IF
       
    END IF
       

    ! ---------- READ numerical_parameters NAMELIST -----------------------------------
    READ(input_unit, numerical_parameters,IOSTAT=ios )
    
    IF ( ios .NE. 0 ) THEN
       
       WRITE(*,*) 'IOSTAT=',ios
       WRITE(*,*) 'ERROR: problem with namelist NUMERICAL_PARAMETERS'
       WRITE(*,*) 'Please check the input file'
       WRITE(*,numerical_parameters)
       STOP
       
    ELSE

       nv2 = nv*nv
       inv_nv2 = 1.0_wp / nv2
       REWIND(input_unit)
       
    END IF

    !------ search for masking thresholds ---------------------------------------

    REWIND(input_unit)

    tend1 = .FALSE.

    WRITE(*,*) 'Searching for masking thresholds'

    n_masking = 0

    masking_search: DO

       READ(input_unit,*, END = 300 ) card

       IF( TRIM(card) == 'MASKING_THRESHOLDS' ) THEN

          EXIT masking_search

       END IF

    END DO masking_search


    READ(input_unit,*) n_masking

    WRITE(*,*) 'n_masking ',n_masking

    ALLOCATE( masking_threshold( n_masking ) )

    DO i = 1, n_masking

       READ(input_unit,*) masking_threshold(i) 

       WRITE(*,'(I4,1X, F6.3)') i , masking_threshold(i)  

    END DO

    GOTO 310
300 tend1 = .TRUE.
310 CONTINUE
    
    !------ end search for masking thresholds -----------------------------------

    ! Initialize loop
    i = 0
    base_name = run_name
    condition = .true.
    
    ! Loop to find a unique run_name
    do while (condition)
       write(run_name, '(A,"_",I3.3)') trim(base_name), i
       
       write(backup_file, '(A,"_inp.bak")') trim(run_name)
       
          ! Check if the file exists
       inquire(file=trim(backup_file), exist=condition)
       
       i = i + 1
    end do

    ! File copy equivalent in Fortran 90
    call execute_command_line("cp mr_lava_loba.inp "//trim(backup_file))
    
    ! Output the run name
    print *, 'Run name ', trim(run_name)
    print *, ''
    
    RETURN

    
  END SUBROUTINE read_param
  
  SUBROUTINE read_topo

    IMPLICIT NONE

    LOGICAL :: lexist

    CHARACTER(LEN=15) :: chara

    INTEGER :: i

    INTEGER :: cols, rows

    REAL(wp), allocatable :: arr_temp(:,:), xc_temp(:), yc_temp(:)
    REAL(wp), allocatable :: xc(:) , yc(:)
    
    REAL(wp) :: xE, xW, yS, yN
    
    INQUIRE(FILE=source,EXIST=lexist)

    IF (lexist) THEN

       OPEN(topo_unit, file=source, status='old', action='read')

    ELSE

       WRITE(*,*) 'no dem file: ',TRIM(source)
       STOP

    ENDIF

    READ(topo_unit,*) chara, cols
    READ(topo_unit,*) chara, rows
    READ(topo_unit,*) chara, lx
    READ(topo_unit,*) chara, ly
    READ(topo_unit,*) chara, cell
    READ(topo_unit,*) chara, nd

    ! Allocate the arrays based on dimensions
    allocate(arr_temp(rows, cols))
    allocate(xc_temp(cols))
    allocate(yc_temp(rows))    

    WRITE(*,*) 'Reading DEM file:',TRIM(source)
    do i = 1, rows

       WRITE(*,FMT="(A1,A,t21,F6.2,A)",ADVANCE="NO") ACHAR(13),              &
            & " Percent Complete: " ,                                        &
            ( REAL(i) / REAL(rows))*100.0, "%"
             
       read(topo_unit, *) arr_temp(rows-i+1, :)
       
    end do

    WRITE(*,*)
    WRITE(*,*)
    
    
    close(topo_unit)    

    IF ( crop_flag) THEN

       ! Calculate cell centers
       do i = 1, cols
          xc_temp(i) = lx + cell * (0.5 + (i - 1))
       end do
       do i = 1, rows
          yc_temp(i) = ly + cell * (0.5 + (i - 1))
       end do
       
       xW = MINVAL(x_vent) - west_to_vent
       xE = MAXVAL(x_vent) + east_to_vent
       yS = MINVAL(y_vent) - south_to_vent
       yN = MAXVAL(y_vent) + north_to_vent

       WRITE(*,*) 'Cropping of original DEM'
       WRITE(*,'(A, 4(F10.1, 1X))') ' xW,xE,yS,yN', xW, xE, yS, yN

       ! crop the DEM to the desired domain
       iW = MAX(1, (floor((xW - lx) / cell)) )
       iE = MIN(cols, (ceiling((xE - lx) / cell)) )
       jS = MAX(1, (floor((yS - ly) / cell)) )
       jN = MIN(rows, (ceiling((yN - ly) / cell)) )

       WRITE(*,*) 'iW,iE,jS,jN', iW, iE, jS, jN
       WRITE(*,*)

       nx = iE-iW+1
       ny = jN-jS+1
       allocate(Ztopo(ny, nx))
       allocate(xc(nx))
       ALLOCATE(yc(ny))
       
       Ztopo = arr_temp(jS:jN,iW:iE)
       xc = xc_temp(iW:iE)
       yc = yc_temp(jS:jN)

       lx = xc(1) - 0.5_wp * cell
       ly = yc(1) - 0.5_wp * cell

       WRITE(*,*) 'lx,ly ',lx,ly
       
    ELSE

       nx = cols
       ny = rows

       allocate(Ztopo(ny, nx))
       Ztopo = arr_temp
       
       allocate(xc(nx))
       ALLOCATE(yc(ny))

       xc(:) = xc_temp(:)
       yc(:) = yc_temp(:)
       
    END IF

    xcmin = MINVAL(xc)
    xcmax = MAXVAL(xc)

    ycmin = MINVAL(yc)
    ycmax = MAXVAL(yc)

    allocate(Xtopo(ny, nx))
    allocate(Ytopo(ny, nx))

    do i = 1, ny

       Xtopo(i, 1:nx) = xc(1:nx)
       Ytopo(i, 1:nx) = yc(i)
    
    end do

    allocate(filling_parameter(ny,nx))

    filling_parameter(1:ny,1:nx) = 1.0_wp - thickening_parameter
    
    RETURN
    
  END SUBROUTINE read_topo


  SUBROUTINE read_restart

    IMPLICIT NONE

    INTEGER :: i
    INTEGER :: i_restart
    REAL(wp), ALLOCATABLE :: Zflow_old(:,:)
    REAL(wp), ALLOCATABLE :: arr_temp(:,:)
    
    LOGICAL :: lexist
    CHARACTER(LEN=15) :: chara

    REAL(wp) :: lx_re, ly_re, cell_re, nd_re
    INTEGER :: cols_re, rows_re

    REAL(wp) :: filling_parameter_i

    ALLOCATE(Zflow_old(ny,nx))    
    
    DO i_restart=1, n_restarts

       WRITE(*,*) "Read restart file ", TRIM(restart_files(i_restart)) 

       INQUIRE(FILE=TRIM(restart_files(i_restart)),EXIST=lexist)
       
       IF (lexist) THEN
          
          OPEN(restart_unit, file=TRIM(restart_files(i_restart)), status='old', action='read')
          
       ELSE
          
          WRITE(*,*) 'no restart file: ',TRIM(restart_files(i_restart))
          STOP
          
       ENDIF
       
       READ(restart_unit,*) chara, cols_re
       READ(restart_unit,*) chara, rows_re
       READ(restart_unit,*) chara, lx_re
       READ(restart_unit,*) chara, ly_re
       READ(restart_unit,*) chara, cell_re
       READ(restart_unit,*) chara, nd_re
       
       CLOSE(restart_unit)

       ALLOCATE( arr_temp(rows_re,cols_re) )
       
       IF ( ( cols_re .EQ. cols ) .AND. ( rows_re .EQ. rows ) .AND. ( lx_re .EQ. lx ) .AND. &
            ( ly_re .EQ. lx) .AND. ( cell_re .EQ. cell ) ) THEN

          WRITE(*,*) "Check on restart size OK"

       ELSE

          WRITE(*,*) "Check on restart size FAILED"
          STOP

       END IF

       DO i = 1, rows_re
          
          read(restart_unit, *) arr_temp(rows_re-i+1, 1:cols_re)
          
       END DO

       IF (crop_flag) THEN

          Zflow_old(1:ny,1:nx) = arr_temp(jS:jN,iW:iE)
          
       ELSE

          Zflow_old(1:ny,1:nx) = arr_temp(1:ny,1:nx)

       END IF
       
       ! Load the relevant filling_parameter (to account for "subsurface flows")
       filling_parameter_i = restart_filling_parameters(i_restart)

       Ztopo = Ztopo + Zflow_old * filling_parameter_i
       
       CLOSE(restart_unit)  
       
    END DO
    
    DEALLOCATE( Zflow_old )
    DEALLOCATE( arr_temp )
    
    RETURN
    
  END SUBROUTINE read_restart

  SUBROUTINE write_masking

    USE flow, ONLY : Zflow

    IMPLICIT NONE

    INTEGER :: i_thr, i , k
    INTEGER :: max_lobes
    ! REAL(wp) :: masked_Zflow(ny,nx)
    INTEGER :: check_term1D(nx)
    REAL(wp) :: total_Zflow, total_masked_Zflow
    REAL(wp) :: threshold
    REAL(wp) :: volume_fraction
    CHARACTER(LEN=40) :: masked_file, masking_str1, masking_str2

    max_lobes = floor(MAXVAL(Zflow)/avg_lobe_thickness)

    ! Sum the values in Zflow
    total_Zflow = sum(Zflow)

    DO i_thr = 1,n_masking

       DO i = 1,10*max_lobes

          threshold = i * 0.1_wp * avg_lobe_thickness

          total_masked_Zflow = 0.0_wp

          DO k = 1,ny

             ! 0-1 mask for flow
             check_term1D = Zflow(k,1:nx) .GT. threshold

             total_masked_Zflow = total_masked_Zflow +       &
                  sum(check_term1D*Zflow(k,1:nx))
             
          END DO

          volume_fraction = total_masked_Zflow / total_Zflow

          IF (volume_fraction < masking_threshold(i_thr)) THEN

             WRITE(*,*)
             WRITE(*,*) 'Masking threshold', masking_threshold(i_thr)
             WRITE(*,*) 'Total volume (m3) =', cell**2 * total_Zflow,                  &
                  'Masked volume (m3) =', cell**2 * total_masked_Zflow,            &
                  'Volume fraction =', volume_fraction
             
             !WRITE(*,*) 'Total area', cell**2 * sum(merge(0,1,Zflow > 0)),      &
             !     ' m2 Masked area',cell**2 * sum(merge(0,1,masked_Zflow > 0)), &
             !     ' m2'
             
             !WRITE(*,*) 'Average thickness full',                               &
             !     total_Zflow / sum(merge(0,1,Zflow > 0)),                      &
             !     ' m Average thickness mask', sum(masked_Zflow) /              &
             !     sum(merge(0,1,masked_Zflow > 0)), ' m'

             ! Convert the masking_threshold value to a string and replace '.' with '_'
             write(masking_str1, '(F6.2)') masking_threshold(i_thr)
             masking_str1 = adjustl(masking_str1)
             call replace_dot(masking_str1, masking_str2)
             
             ! Concatenate the strings
             masked_file = trim(run_name) // '_thickness_masked_' // trim(masking_str2) // '.asc'
             
             CALL write_asc(Zflow, masked_file, lx, ly, cell, 0.0_wp, masking_threshold(i_thr))
             
             EXIT
             
          END IF
          
       END DO

    END DO

  END SUBROUTINE write_masking
  

  SUBROUTINE write_asc(out_array, output_file, x0, y0, cell_size, nodata, threshold)

    IMPLICIT NONE

    REAL(wp), INTENT(IN) :: out_array(:,:)
    CHARACTER*40, INTENT(IN) :: output_file
    REAL(wp), INTENT(IN) :: x0, y0
    REAL(wp), INTENT(IN) :: cell_size
    REAL(wp), INTENT(IN) :: nodata
    REAL(wp), INTENT(IN) :: threshold

    INTEGER :: check_term1D(size(out_array,2))
    REAL(wp) ::out_array1D(size(out_array,2))
    
    INTEGER :: out_cells_x, out_cells_y
    INTEGER :: j

    OPEN(output_unit,FILE=TRIM(output_file),status='unknown',form='formatted')

    out_cells_y = size(out_array, 1)
    out_cells_x = size(out_array, 2)
    
    WRITE(output_unit,'(A,I5)') 'ncols ', out_cells_x
    WRITE(output_unit,'(A,I5)') 'nrows ', out_cells_y
    WRITE(output_unit,'(A,F15.3)') 'xllcorner ', x0
    WRITE(output_unit,'(A,F15.3)') 'yllcorner ', y0
    WRITE(output_unit,'(A,F15.3)') 'cellsize ', cell_size
    WRITE(output_unit,'(A,F15.3)') 'NODATA_value ', nodata

    DO j = out_cells_y,1,-1

       check_term1D = out_array(j,1:out_cells_x) .GT. threshold
       out_array1D = check_term1D * out_array(j,1:out_cells_x)
       WRITE(output_unit,'(2000ES12.3E3)') out_array1D
       
       ! WRITE(output_unit,'(2000ES12.3E3)') out_array(j,1:out_cells_x)

    ENDDO

    CLOSE(output_unit)
    
  END SUBROUTINE write_asc

    subroutine replace_dot(in_str, out_str)
        character(len=*), intent(in) :: in_str
        character(len=*), intent(out) :: out_str
        integer :: i
        out_str = in_str
        do i = 1, len_trim(in_str)
            if (out_str(i:i) == '.') out_str(i:i) = '_'
        end do
    end subroutine replace_dot
  
END MODULE inpout
