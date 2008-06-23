C                                                                               
C  Copyright 1990  Regents of the University of California                      
C                                                                               
C                                                                               
C  Author:  Dave Harris                                                         
C                                                                               
C           Lawrence Livermore National Laboratory                              
C           L-205                                                               
C           P.O. Box 808                                                        
C           Livermore, CA  94550                                                
C           USA                                                                 
C                                                                               
C           (415) 423-0617                                                      
C                                                                               
C                                                                               
C  CHEBPARM - Calculates Chebyshev type I and II design parameters              
C                                                                               
C                                                                               
C  INPUT ARGUMENTS                                                              
C  ---------------                                                              
C                                                                               
C       A                Desired stopband attenuation                           
C                          i.e. max stopband amplitude is 1/ATTEN               
C                                                                               
C       TRBNDW           Transition bandwidth between stop and passbands        
C                          as a fraction of the passband width                  
C                                                                               
C       IORD             Filter order (number of poles)                         
C                                                                               
C                                                                               
C  OUTPUT ARGUMENTS                                                             
C  ----------------                                                             
C                                                                               
C       EPS              Chebyshev passband parameter                           
C                                                                               
C       RIPPLE           Passband ripple                                        
C                                                                               
      SUBROUTINE CHEBPARM( A, TRBNDW, IORD, EPS, RIPPLE )               

          IMPLICIT NONE
                                                                        
          REAL*4 A,TRBNDW,EPS,RIPPLE
          INTEGER IORD

          REAL*4 OMEGAR,ALPHA,G

          OMEGAR  =  1. + TRBNDW                                        
          ALPHA = ( OMEGAR + SQRT( OMEGAR**2 - 1. ) ) ** IORD           
          G = ( ALPHA**2 + 1. ) / (2.*ALPHA)                            
          EPS = SQRT( A**2 - 1. ) / G                                   
          RIPPLE = 1. / SQRT( 1. + EPS**2 )                             
C                                                                               
      RETURN                                                            
      END                                                               
                                                                        
