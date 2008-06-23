      double precision function taper(freq,fqh,fql)
C
C SUBROUTINE TO TAPER SPECTRA BY A COSINE
C
C CALLING ARGUMENTS:
C
C     FREQ - FREQUENCY IN QUESTION
C     FQH - FREQUENCY AT WHICH THERE IS A TRANSITION BETWEEN UNITY AND
C           THE TAPER
C     FQL - FREQUENCY AT WHICH THERE IS A TRANSITION BETWEEN ZERO AND THE
C           TAPER
C     NOTE:  IF FQL>FQH   LO-PASS
C            IF FQH>FQL   HI-PASS
C
      implicit real*8(a-h,o-z)
      implicit character*8 (k)
      implicit logical (l)
      implicit integer (i,j,m,n)
      data twopi /6.283185307179586/
C
      dblepi=0.5d0*twopi
      if (fql .gt. fqh) go to 210
      if (fqh .gt. fql) go to 510
      write (munout,110)
  110 format (' INVALID WINDOW SPECIFIED')
      return
C
C LO-PASS CASE
C
  210 if (freq .lt. fqh) taper=1.0d0
      if (freq .ge. fqh .and. freq .le. fql)
     1   taper=0.5d0*(1.0d0+dcos(dblepi*(freq-fqh)/(fql-fqh)))
      if (freq .gt. fql) taper=0.0d0
C
      return
C
C HI-PASS CASE
C
  510 if (freq .lt. fql) taper=0.0d0
      if (freq .ge. fql .and. freq .le. fqh)
     1   taper=0.5d0*(1.0d0-dcos(dblepi*(freq-fql)/(fqh-fql)))
      if (freq .gt. fqh) taper=1.0d0
C
      return
C
      end

