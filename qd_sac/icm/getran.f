      subroutine getran ( nfreq, delfrq, const, nzero, zero,
     .         npole, pole, xre, xim )
c
c   .....Subroutine to compute the transfer function.....
c
      implicit none
      integer nfreq,nzero,npole
      real * 8 delfrq, xre(1), xim(1)
      real * 4 const
      complex zero(1), pole(1)

      real * 8 twopi,delomg, omega, trn, tin,
     .   tr, ti, tr0, ti0, trd, tid, fac
      integer i,j

      data twopi / 6.283185307179586 d0 /
c
      delomg = twopi * delfrq
c
	 do 30 j = 1, nfreq
	 omega = delomg * dfloat(j-1)
	 trn = 1.0 d0
	 tin = 0.0 d0
c
	 if ( nzero .ne. 0 ) then
	    do 10 i = 1, nzero
	    tr = - real ( zero(i) )
	    ti = omega - aimag ( zero(i) )
	    tr0 = trn * tr - tin * ti
	    ti0 = trn * ti + tin * tr
	    trn = tr0
	    tin = ti0
   10       continue
	 end if
c
      trd = 1.0 d0
      tid = 0.0 d0
c
      if ( npole .ne. 0 ) then
	 do 20 i = 1, npole
	 tr = - real ( pole(i) )
	 ti = omega - aimag ( pole(i) )
	 tr0 = trd * tr - tid * ti
	 ti0 = trd * ti + tid * tr
	 trd = tr0
	 tid = ti0
   20    continue
      end if
c
      fac = dble ( const ) / ( trd ** 2 + tid ** 2 )
      xre(j) = fac * ( trn * trd + tin * tid )
      xim(j) = fac * ( trd * tin - trn * tid )
   30 continue
c
      return
      end
