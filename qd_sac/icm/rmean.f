      subroutine rmean(dat,npts)

c  remove mean from data

      implicit none

      integer npts
      real*4 dat(npts),sum
      integer i
      

      sum=0
      do i = 1, npts
         sum = sum + dat(i)
      enddo
      do i = 1, npts
         dat(i) = dat(i) - sum/npts
      enddo
 
      return
      
      end
