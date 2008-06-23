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
C BUROOTS -- SUBROUTINE TO COMPUTE BUTTERWORTH POLES FOR                        
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
C      DCVALUE        MAGNITUDE OF FILTER AT ZERO FREQUENCY                     
C                                                                               
C      NSECTS         NUMBER OF SECOND ORDER SECTIONS                           
C                                                                               
C  INPUT ARGUMENTS:                                                             
C  ----------------                                                             
C                                                                               
C      IORD           DESIRED FILTER ORDER                                      
C                                                                               
C                                                                               
      SUBROUTINE BUROOTS( P, RTYPE, DCVALUE, NSECTS, IORD )             
C                    
                                                           
        IMPLICIT NONE
        COMPLEX P(1)                                                    
        CHARACTER*3 RTYPE(1)                                            
        REAL*4 DCVALUE
        INTEGER NSECTS,IORD

        REAL*4 PI,ANGLE
        INTEGER HALF,K
        

C                                                                               
        PI=3.14159265                                                   
C                                                                               
        HALF = IORD/2                                                   
C                                                                               
C TEST FOR ODD ORDER, AND ADD POLE AT -1                                        
C                                                                               
        NSECTS = 0                                                      
        IF (    2*HALF .LT. IORD ) THEN                                 
          P(1) = CMPLX( -1., 0. )                                       
          RTYPE(1) = 'SP'                                               
          NSECTS = 1                                                    
        END IF                                                          
C                                                                               
        DO    1  K = 1, HALF                                            
          ANGLE = PI * ( .5 + FLOAT(2*K-1) / FLOAT(2*IORD) )            
          NSECTS = NSECTS + 1                                           
          P(NSECTS) = CMPLX( COS(ANGLE), SIN(ANGLE) )                   
          RTYPE(NSECTS) = 'CP'                                          
    1   CONTINUE                                                        
C                                                                               
        DCVALUE = 1.0                                                   
C                                                                               
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
                                                                        
                                                                        
                                                                        
                                                                        
