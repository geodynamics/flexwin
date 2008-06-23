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
C C1ROOTS -- SUBROUTINE TO COMPUTE CHEBYSHEV TYPE I POLES FOR                   
C   NORMALIZED LOWPASS FILTER                                                   
C                                                                               
C LAST MODIFIED:  SEPTEMBER 7, 1990                                             
C                                                                               
C  OUTPUT ARGUMENTS:                                                            
C  -----------------                                                            
C      P              COMPLEX ARRAY CONTAINING POLES                            
C                       CONTAINS ONLY ONE FROM EACH                             
C                       COMPLEX CONJUGATE PAIR, AND                             
C                       ALL REAL POLES                                          
C                                                                               
C      RTYPE          CHARACTER ARRAY INDICATING 2ND ORDER SECTION              
C                       TYPE:                                                   
C                         (SP)  SINGLE REAL POLE                                
C                         (CP)  COMPLEX CONJUGATE POLE PAIR                     
C                         (CPZ) COMPLEX CONJUGATE POLE-ZERO PAIRS               
C                                                                               
C      DCVALUE        RESPONSE OF FILTER AT ZERO FREQUENCY                      
C                                                                               
C      NSECTS         NUMBER OF SECOND ORDER SECTIONS                           
C                                                                               
C  INPUT ARGUMENTS:                                                             
C  ----------------                                                             
C                                                                               
C      IORD           DESIRED FILTER ORDER                                      
C                                                                               
C      EPS            CHEBYSHEV PARAMETER RELATED TO PASSBAND RIPPLE            
C                                                                               
      SUBROUTINE C1ROOTS( P, RTYPE, DCVALUE, NSECTS, IORD, EPS )   

        IMPLICIT NONE
C                                                                               
        COMPLEX P(1)                        
        CHARACTER*3 RTYPE(1)
        REAL*4 DCVALUE,EPS
        INTEGER NSECTS,IORD
                                                                              
        REAL*4 PI,GAMMA,S,C,ANGLE,SIGMA,OMEGA
        INTEGER HALF,I

        PI = 3.14159265                                                 
        HALF = IORD/2                                                   
C                                                                               
C  INTERMEDIATE DESIGN PARAMETERS                                               
C                                                                               
        GAMMA = ( 1. + SQRT( 1. + EPS*EPS ) ) / EPS                     
        GAMMA = ALOG(GAMMA) / FLOAT(IORD)                               
        GAMMA = EXP(GAMMA)                                              
        S = .5 * ( GAMMA - 1./GAMMA )                                   
        C = .5 * ( GAMMA + 1./GAMMA )                                   
C                                                                               
C  CALCULATE POLES                                                              
C                                                                               
        NSECTS = 0                                                      
        DO    1  I = 1 ,  HALF                                          
          RTYPE(I) = 'CP'                                               
          ANGLE = FLOAT(2*I-1) * PI/FLOAT(2*IORD)                       
          SIGMA = -S * SIN(ANGLE)                                       
          OMEGA =  C * COS(ANGLE)                                       
          P(I) = CMPLX( SIGMA, OMEGA )                                  
          NSECTS = NSECTS + 1                                           
    1   CONTINUE                                                        
        IF (   2*HALF .LT. IORD ) THEN                                  
          RTYPE( HALF + 1 ) = 'SP'                                      
          P(HALF+1) = CMPLX( -S, 0.0 )                                  
          NSECTS = NSECTS + 1                                           
          DCVALUE = 1.0                                                 
        ELSE                                                            
          DCVALUE = 1./SQRT( 1 + EPS**2 )                               
        END IF                                                          
C                                                                               
C  DONE                                                                         
C                                                                               
      RETURN                                                            
      END                                                               
                                                                        
