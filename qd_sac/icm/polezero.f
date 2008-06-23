      subroutine polezero ( nfreq, delfrq, xre, xim , subtyp, nerr)

c     generic transfer function - user supplies poles and zeros


      implicit none
      integer mpoles,mzeros
      parameter (mpoles=30)
      parameter (mzeros=30)

      integer nfreq
      real*8 delfrq,xre(1),xim(1)
      integer nerr

      integer nzeros,npoles,izeros,ipoles,i,iofile
      logical lzeros,lpoles,lexist
      complex zeros(mzeros)		
      complex poles(mpoles)	
      real*4 const,re,im
      character*(*) subtyp
      character*200  kline



* - Set default values for constant, poles, and zeros.

 5000 const=1.0

      do 5010 i=1,mzeros
 5010   zeros(i)=cmplx ( 0.0, 0.0 )

      do 5011 i=1,mpoles
 5011   poles(i)=cmplx ( 0.0, 0.0 )


* - Open file.
      lexist = .true.
      iofile = 10
      do while (lexist)
        iofile = iofile + 1
        inquire(iofile,exist = lexist)
      enddo
      open(iofile,file=subtyp,status='old',iostat=nerr)
      if (nerr .ne. 0) then
         print *, 'Not able to open polezero file'
         return
      endif

* - Read and decode lines in file.

      lpoles=.FALSE.
      lzeros=.FALSE.
      ipoles = 1
      izeros = 1
 6000 read(iofile,'(a)',end=7000,err=9000) kline
      if (kline(1:5) .eq. 'ZEROS') then
         read(kline(6:),*,iostat=nerr) nzeros
         lzeros = .TRUE.
      else if (kline(1:5) .eq. 'POLES') then
         read(kline(6:),*,iostat=nerr) npoles
         lpoles = .TRUE.
      else if (kline(1:8) .eq. 'CONSTANT') then
         read(kline(9:),*,iostat = nerr) const
         goto 7000
      else if (lpoles) then
         read(kline,*,iostat=nerr) re,im
         poles(ipoles) = cmplx(re,im)
         ipoles = ipoles + 1
         if (ipoles > mpoles) then
            print *, 'Too many poles'
            return
         endif
      else if (lzeros) then
         read(kline,*,iostat=nerr) re,im
         zeros(izeros) = cmplx(re,im)
         izeros = izeros + 1
         if (izeros > mpoles) then
            print *, 'Too many zeros'
            return
 3       endif
      endif         
      if (nerr .ne. 0) goto 9000
      go to 6000

 7000 close(iofile)
* - Compute transfer function.

      call getran ( nfreq, delfrq, const, nzeros, zeros, npoles,
     #              poles, xre, xim )

      return

 9000 print *, 'Error reading pole zero file'
      return

      end
