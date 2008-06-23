      subroutine rtrend(y, n) 

c      remove trend a*i + b 
c      revised from lupei's c code

      implicit none

      real*4 y(1)
      integer n,i
      real*8  a, b, a11, a12, a22, y1, y2

      y1 = 0.
      y2 = 0.
      do i = 1, n
        y1 = y1 + (i-1)*y(i)
        y2 = y2 + y(i);
      enddo
      a12 = 0.5*n*(n-1)
      a11 = a12*(2*n-1)/3.
      a22 = n;
      b = a11*a22-a12*a12
      a = (a22*y1-a12*y2)/b
      b = (a11*y2-a12*y1)/b
      do i = 1, n
       y(i) = y(i) - a * (i-1) - b
      enddo
      
      return
      end 

 
