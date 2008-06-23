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
C C2ROOTS -- SUBROUTINE TO COMPUTE ROOTS FOR NORMALIZED LOWPASS                 
C   CHEBYSHEV TYPE 2 FILTER                                                     
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
C      Z              COMPLEX ARRAY CONTAINING ZEROS                            
C                       CONTAINS ONLY ONE FROM EACH                             
C                       COMPLEX CONJUGATE PAIR, AND                             
C                       ALL REAL ZEROS                                          
C                                                                               
C      RTYPE          CHARACTER ARRAY INDICATING 2ND ORDER SECTION              
C                       TYPE:                                                   
C                         (SP)  SINGLE REAL POLE                                
C                         (CP)  COMPLEX CONJUGATE POLE PAIR                     
C                         (CPZ) COMPLEX CONJUGATE POLE-ZERO PAIRS               
C                                                                               
C      DCVALUE        MAGNITUDE OF FILTER AT ZERO FREQUENCY                     
C                                                                               
C      NSECTS         NUMBER OF SECOND ORDER SECTIONS                           
C                                                                               
C  INPUT ARGUMENTS:                                                             
C  ----------------                                                             
C                                                                               
C                                                                               
C      IORD           DESIRED FILTER ORDER                                      
C                                                                               
C      A              STOPBAND ATTENUATION FACTOR                               
C                                                                               
C      OMEGAR         CUTOFF FREQUENCY OF STOPBAND                              
C                     PASSBAND CUTOFF IS AT 1.0 HERTZ                           
C                                                                               
C                                                                               
      SUBROUTINE C2ROOTS( P, Z, RTYPE, DCVALUE, NSECTS, IORD, A, OMEGAR)

                                                                 
        IMPLICIT NONE
        COMPLEX P(1), Z(1)                                              
        CHARACTER*3 RTYPE(1)
        REAL*4 DCVALUE,A,OMEGAR
        INTEGER NSECTS,IORD
                                                                               
        REAL*4 PI,GAMMA,S,C,ANGLE,ALPHA,BETA,DENOM,SIGMA,OMEGA
        INTEGER HALF,I


        PI = 3.14159265                                                 
        HALF = IORD/2                                                   
C                                                                               
C  INTERMEDIATE DESIGN PARAMETERS                                               
C                                                                               
        GAMMA = (A+SQRT(A*A-1.))                                        
        GAMMA = ALOG(GAMMA)/FLOAT(IORD)                                 
        GAMMA = EXP(GAMMA)                                              
        S = .5*(GAMMA-1./GAMMA)                                         
        C = .5*(GAMMA+1./GAMMA)                                         
C                                                                               
        NSECTS = 0                                                      
        DO    1 I = 1, HALF                                             
C                                                                               
C  CALCULATE POLES                                                              
C                                                                               
          RTYPE(I) = 'CPZ'                                              
C                                                                               
          ANGLE = FLOAT(2*I-1) * PI/FLOAT(2*IORD)                       
          ALPHA = -S*SIN(ANGLE)                                         
          BETA = C*COS(ANGLE)                                           
          DENOM = ALPHA*ALPHA + BETA*BETA                               
          SIGMA = OMEGAR*ALPHA/DENOM                                    
          OMEGA = -OMEGAR*BETA/DENOM                                    
          P(I) = CMPLX( SIGMA, OMEGA )                                  
C                                                                               
C  CALCULATE ZEROS                                                              
C                                                                               
          OMEGA = OMEGAR/COS(ANGLE)                                     
          Z(I) = CMPLX( 0.0, OMEGA )                                    
C                                                                               
          NSECTS = NSECTS + 1                                           
C                                                                               
    1   CONTINUE                                                        
C                                                                               
C  ODD-ORDER FILTERS                                                            
C                                                                               
        IF (  2*HALF .LT. IORD ) THEN                                   
          RTYPE(HALF+1) = 'SP'                                          
          P(HALF+1) = CMPLX( -OMEGAR/S, 0.0 )                           
          NSECTS = NSECTS + 1                                           
        END IF                                                          
C                                                                               
C  DC VALUE                                                                     
C                                                                               
        DCVALUE = 1.0                                                   
C                                                                               
C  DONE                                                                         
C                                                                               
      RETURN                                                            
      END                                                               
