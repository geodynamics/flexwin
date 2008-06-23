      subroutine transfer(dat,npts,delta,kpfrom,kpto,f, &
           nerr)

!=====================================================================
! PURPOSE:  To apply an instrument transfer function to a data set.
!=====================================================================
! INPUT ARGUMENTS:
!      dat(npts) :  data array
!      delta     :  dt
!      kpfrom    : 'from' pzfiles
!      kpto      :  'to' pzfiles
!      f(4) :  filter frequencies
!=====================================================================
! OUTPUT ARGUMENTS:
!      dat(npts) is modified to the transfered data
!=====================================================================
! MODULE/LEVEL:  ICM/4
!=====================================================================
! SUBROUTINES CALLED:
!   dseis(polezero,getran),taper,dcpft
!=====================================================================
! MODIFICATION HISTORY:
!    871023:  Major restructuring of instrument parameter storage.
!    870317:  Now passing in work arrays rather than using local ones.
!    870219:  Added prewhiten/dewhiten for flatter spectrum
!             and changed order of spectral operations
!    861105:  Original version from K. Nakanishi's TRANSFER program.
!=======================================================================
! DOCUMENTED/REVIEWED:  870317
!=====================================================================
! BUFFER NEEDED:
!     sre(nfft),sim(nfft)  : buffer to hold data fft
!      xre(nfreq),xim(nfreq) : hold the filter frequency response.
!========================================================================



      implicit none

      integer npts
      real*4 dat(npts)
      real*4 delta,f(4)

      character(len=*) kpfrom(2), kpto(2)

      real*8, dimension(:), allocatable ::  sre, sim, xre, xim
      real*8  :: delfrq, fac, freq, taper
      real*8  :: srej,srei,simj,simi,xrej,ximj,denr,aa,bb
      real*4 :: a(21)

      integer :: nfft,nfreq,error,nerr
      integer :: i,j,next2

! PROCEDURE:


      nfft = next2(npts)
      nfreq = nfft/2 + 1
      delfrq = 1.0d0 / ( dfloat ( nfft ) * dble ( delta ) )


! allocate memory for arrays

      allocate(sre(nfft),sim(nfft),xre(nfreq),xim(nfreq),stat=nerr)
      if (nerr /= 0) stop 'Error allocating memory for transfer function'

! - Deconvolve seismometer.

      call dseis(nfreq,delfrq,xre,xim,kpfrom,nerr)
      if(nerr.ne.0)go to 8888

      do 30 i = 2, nfreq
        denr = 1.0d0 / ( xre(i)**2 + xim(i)**2 )
        sre(i) =  xre(i) * denr
        sim(i) = - xim(i) * denr
   30   continue

! - Determine seismometer transfer function.

      call dseis(nfreq,delfrq,xre,xim,kpto,nerr)
      if(nerr.ne.0)go to 8888

      do 50 i = 2, nfreq
	freq = dfloat(i-1) * delfrq
        srej = sre(i)
        simj = sim(i)
        xrej = xre(i)
        ximj = xim(i)
        srei = xrej * srej - ximj * simj
        simi = xrej * simj + ximj * srej
        fac = delfrq * taper ( freq, dble(f(2)), dble(f(1)) ) &
                    * taper ( freq, dble(f(3)), dble(f(4)) )
        aa = srei * fac
        bb = simi * fac
        xre(i) = aa
        xim(i) = bb
   50   continue

! - Transform the data.

      do 10 i = 1, npts
        sre(i) = dble ( dat(i) ) * dble ( delta )
        sim(i) = 0.0d0
   10   continue
      do 11 i = npts + 1, nfft
        sre(i) = 0.0d0
        sim(i) = 0.0d0
   11   continue

      call dcpft ( sre, sim, nfft, 1, -1 )

! - Multiply by the transfer operator.

      do 15 i = 2, nfreq
        freq = dfloat(i-1) * delfrq
        srej = sre(i)
        simj = sim(i)
        xrej = xre(i)
        ximj = xim(i)
        aa = xrej * srej - ximj * simj
        bb = xrej * simj + ximj * srej
        sre(i) = aa
        sim(i) = bb
        j = nfft - i + 2
        sre(j) = aa
        sim(j) = -bb
   15   continue

      sre(1) = 0.0d0
      sim(1) = 0.0d0
      sre(nfreq) = dsqrt ( sre(nfreq)**2 + sim(nfreq)**2 )
      sim(nfreq) = 0.0d0

! - Perform the inverse transform.

      call dcpft ( sre, sim, nfft, 1, 1 )

! - Copy the transformed data back into the original data array.

      do 60 i = 1, npts
        dat(i) = sre(i)
   60 continue


8888    deallocate(sre,sim,xre,xim)
        return

      end
