      subroutine dseis(nfreq,delfrq,xre,xim,kp,nerr)

c   .....Branching routine to apply the individual instrument responses.
c
c MODIFICATIONS:
c    920420:  Changed adjustable array specifier from "1" to "*".
c    900409:  Added LNN instrument type.
c
      implicit none

      real*8 delfrq,xre(*),xim(*)
      integer nfreq,nerr,i
      character*(*) kp(2)
      

      nerr=0

      do 10 i=1,nfreq
	xre(i)=1.0 d0
	xim(i)=0.0 d0
   10   continue

 
c  one might consider adding more instruments if needed in application

      if(trim(kp(1)).eq.'POLEZERO')then
        call polezero(nfreq,delfrq,xre,xim,kp(2),nerr)
      else if (trim(kp(1)) .ne. 'NONE') then
         print *,'pz files is the only format supported at this stage'
         nerr = 1
      endif
        
      return
      
      end
