!********************************************************************************
!> @brief Main program of MrLavaLoba2.
!!
!! This is the main program of MrLavaLoba2.
!! It initializes the model parameters, reads the input data and the
!! topography, prepares the internal source representation, allocates the
!! main flow arrays, and runs the lava-emplacement simulation.
!!
!! Copyright (c) Mattia de' Michieli Vitturi and Simone Tarquini
!! Licensed under the Apache License, Version 2.0
!! Original authors:
!!   Mattia de' Michieli Vitturi
!!   Simone Tarquini
!! Affiliation:
!!   Istituto Nazionale di Geofisica e Vulcanologia (INGV), Sezione di Pisa!!
!! @date 2026-04-02
!! @author M. de' Michieli Vitturi
!! @author S. Tarquini
!********************************************************************************

PROGRAM mr_lava_loba

   USE inpout, ONLY : run_name
   USE parameters, ONLY : wp
   USE parameters, ONLY : union_diff_flag
   USE parameters, ONLY : lx, ly, cell
   USE flow

   USE flow, ONLY : allocate_flow, init_sources, flow_loop, build_source_cdf
   USE inpout, ONLY : init_param, read_param, read_topo, write_asc
   USE inpout, ONLY : write_masking, write_netcdf_2d, init_union_diff
   USE inpout, ONLY : eval_union_diff
   USE parameters, ONLY : init_run
   USE inpout, ONLY : nc_flag, asc_flag

   IMPLICIT NONE

   CHARACTER*50 :: output_file
   REAL(wp) :: t2 , t3
   INTEGER :: st2 , st3 , cr , cm
   REAL(wp) :: rate

   ! First initialize the system_clock
   CALL system_clock(count_rate=cr)
   CALL system_clock(count_max=cm)
   rate = cr

   WRITE(*,*)
   WRITE(*,*) "Mr Lava Loba by M.de' Michieli Vitturi and S.Tarquini"
   WRITE(*,*)

   CALL init_param

   CALL read_param

   CALL read_topo

   CALL init_run

   CALL init_sources

   CALL build_source_cdf

   CALL allocate_flow

   IF (union_diff_flag) CALL init_union_diff

   WRITE(*,*) 'End pre-processing'
   WRITE(*,*)

   CALL cpu_time(t2)
   CALL system_clock(st2)

   CALL flow_loop

   CALL cpu_time(t3)
   CALL system_clock(st3)

   WRITE(*,*) 'Time taken by flow loop is',t3-t2,'seconds'
   WRITE(*,*) 'Elapsed real time = ', DBLE( st3 - st2 ) / rate,'seconds'

   IF ( nc_flag) THEN

      output_file = trim(run_name) // '_thickness_full' // '.nc'
      CALL write_netcdf_2d(Zflow, output_file, lx, ly, cell, 0.0_wp, 'm', 33 )

   END IF

   IF ( asc_flag ) THEN

      output_file = trim(run_name) // '_thickness_full' // '.asc'
      CALL write_asc(Zflow, output_file, lx, ly, cell, 0.0_wp)

   END IF

   IF (union_diff_flag) THEN

      CALL eval_union_diff(Zflow, 1.0_wp)

   END IF

   CALL write_masking


END PROGRAM mr_lava_loba



