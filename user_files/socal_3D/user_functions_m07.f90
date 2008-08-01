! -------------------------------------------------------------
! Edit here to change the time dependent properties of the selection criteria
! Note, this function is called AFTER the seismogram has been read.
! -------------------------------------------------------------
subroutine set_up_criteria_arrays
  use seismo_variables 

  integer :: i
  double precision :: time

  ! for qinya's scsn picking
  double precision :: Pnl_start, S_end, Sw_start, Sw_end
 
!===========================

! -----------------------------------------------------------------
! This is the basic version of the subroutine - no variation with time
! -----------------------------------------------------------------
   do i = 1, npts
     time = b+(i-1)*dt
     DLNA_LIMIT(i) = DLNA_BASE
     CC_LIMIT(i) = CC_BASE
     TSHIFT_LIMIT(i) = TSHIFT_BASE       ! WIN_MIN_PERIOD/2.0
     STALTA_W_LEVEL(i) = STALTA_BASE
     S2N_LIMIT(i) = WINDOW_AMP_BASE
   enddo

!!$  if (.not. BODY_WAVE_ONLY) then
!!$     Pnl_start =  -5.0 + dist_km/7.8
!!$     Sw_start  = -15.0 + dist_km/3.5
!!$     Sw_end    =  35.0 + dist_km/3.1
!!$  else
!!$     Pnl_start =  P_pick - 5.0
!!$     S_end     =  S_pick + 5.0
!!$     Sw_start  = -15.0 + dist_km/3.5
!!$     Sw_end    =  35.0 + dist_km/3.1
!!$  endif

  ! regional (Qinya's formulation):
  ! -------------------------------------------------------------
  ! see Liu et al. (2004), p. 1755, but note that the PARENTHESES
  ! that are listed in the publication should not be there
  ! THESE ARE PROBABLY NOT ACCURATE ENOUGH FOR LONGER PATHS.
  if (BODY_WAVE_ONLY) then
     !Pnl_start =  P_pick - 5.0
     !S_end     =  S_pick + 5.0
     Pnl_start =  P_pick - 2.5*WIN_MIN_PERIOD
     S_end     =  S_pick + 2.5*WIN_MIN_PERIOD
     Sw_start  = -15.0 + dist_km/3.5
     Sw_end    =  35.0 + dist_km/3.1

  else
     Pnl_start =  -5.0 + dist_km/7.8
     Sw_start  = -15.0 + dist_km/3.5
     Sw_end    =  35.0 + dist_km/3.1
     S_end     =  Sw_start
  endif

  ! variables for signal to noise ratio criteria.
  signal_end = Sw_end
  noise_end  = Pnl_start
  if(DEBUG) then
     write(*,*) 'DEBUG : P_pick = ', sngl(P_pick)
     write(*,*) 'DEBUG : signal_end = ', sngl(sigmal_end)
     write(*,*) 'DEBUG : noise_end = ', sngl(noise_end)
  endif

 ! --------------------------------
 ! modulate criteria in time
  do i = 1, npts
     time = b+(i-1)*dt     ! time

     ! raises STA/LTA water level before P wave arrival.
     if(time.lt.Pnl_start) then
        STALTA_W_LEVEL(i) = 10.*STALTA_BASE
     endif

     ! raises STA/LTA water level after surface wave arrives
     !if (BODY_WAVE_ONLY) then
     !   if(time.gt.S_end) then
     !      STALTA_W_LEVEL(i) = 10.*STALTA_BASE
     !   endif
     !
     !else
!!$        ! set time- and distance-specific Tshift and DlnA to mimic Qinya's criteria
!!$        ! (see Liu et al., 2004, p. 1755; note comment above)
!!$        if(time.ge.Pnl_start .and. time.lt.Sw_start) then
!!$           !DLNA_LIMIT(i) = 1.5  ! ratio is 2.5, and dlna is ratio-1
!!$           TSHIFT_LIMIT(i) = 3.0 + dist_km/80.0
!!$        endif
!!$        if(time.ge.Sw_start .and. time.le.Sw_end) then
!!$           !DLNA_LIMIT(i) = 1.5  ! ratio is 2.5, and dlna is ratio-1
!!$           TSHIFT_LIMIT(i) = 3.0 + dist_km/50.0
!!$        endif

        ! double the STA/LTA water level after the surface waves
        !if(time.gt.Sw_end) then
        !   STALTA_W_LEVEL(i) = 2.0*STALTA_BASE
        !endif

     !endif

  enddo

! The following is for check_window quality_s2n

! -----------------------------------------------------------------
! Start of user-dependent portion

! This is where you modulate the time dependence of the selection
! criteria.  You have access to the following parameters from the 
! seismogram itself:
!
! dt, b, kstnm, knetwk, kcmpnm
! evla, evlo, stla, stlo, evdp, azimuth, backazimuth, dist_deg, dist_km
! num_phases, ph_names, ph_times
!
! Example of modulation:
!-----------------------
! To increase s2n limit after arrival of R1 try
!
! R_vel=3.2
! R_time=dist_km/R_vel
! do i = 1, npts
!   time=b+(i-1)*dt
!   if (time.gt.R_time) then
!     S2N_LIMIT(i)=2*WINDOW_AMP_BASE
!   endif
! enddo
!
! End of user-dependent portion
! -----------------------------------------------------------------

end subroutine set_up_criteria_arrays
! -------------------------------------------------------------
