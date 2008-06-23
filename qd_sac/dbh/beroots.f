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
C BEROOTS -- SUBROUTINE TO RETURN BESSEL POLES FOR                              
C   NORMALIZED LOWPASS FILTER                                                   
C                                                                               
C LAST MODIFIED:  April 15, 1992. Changed P and RTYPE to adjustable 
C                 array by using an "*" rather than a "1".     
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
      SUBROUTINE BEROOTS( P, RTYPE, DCVALUE, NSECTS, IORD )             
C                                                                               
        IMPLICIT NONE
        COMPLEX P(*)                                                    
        INTEGER NSECTS, IORD                                            
        CHARACTER*3 RTYPE(*)
        REAL*4 DCVALUE

C                                                                               
        IF (   IORD .EQ. 1 ) THEN                                       
C                                                                               
          P(1) = CMPLX( -1.0, 0.0 )                                     
          RTYPE(1) = 'SP'                                               
C                                                                               
        ELSE IF (  IORD .EQ. 2 ) THEN                                   
C                                                                               
          P(1) = CMPLX( -1.1016013,  0.6360098 )                        
          RTYPE(1) = 'CP'                                               
C                                                                               
        ELSE IF (  IORD .EQ. 3 ) THEN                                   
C                                                                               
          P(1) = CMPLX( -1.0474091, 0.9992645 )                         
          RTYPE(1) = 'CP'                                               
          P(2) = CMPLX( -1.3226758, 0.0 )                               
          RTYPE(2) = 'SP'                                               
C                                                                               
        ELSE IF (  IORD .EQ. 4 ) THEN                                   
C                                                                               
          P(1) = CMPLX( -0.9952088,  1.2571058 )                        
          RTYPE(1) = 'CP'                                               
          P(2) = CMPLX( -1.3700679, 0.4102497 )                         
          RTYPE(2) = 'CP'                                               
C                                                                               
        ELSE IF (  IORD .EQ. 5 ) THEN                                   
C                                                                               
          P(1) = CMPLX( -0.9576766,  1.4711244 )                        
          RTYPE(1) = 'CP'                                               
          P(2) = CMPLX( -1.3808774,  0.7179096 )                        
          RTYPE(2) = 'CP'                                               
          P(3) = CMPLX( -1.5023160, 0.0 )                               
          RTYPE(3) = 'SP'                                               
C                                                                               
        ELSE IF (  IORD .EQ. 6 ) THEN                                   
C                                                                               
          P(1) = CMPLX( -0.9306565,  1.6618633 )                        
          RTYPE(1) = 'CP'                                               
          P(2) = CMPLX( -1.3818581,  0.9714719 )                        
          RTYPE(2) = 'CP'                                               
          P(3) = CMPLX( -1.5714904,  0.3208964 )                        
          RTYPE(3) = 'CP'                                               
C                                                                               
        ELSE IF (  IORD .EQ. 7 ) THEN                                   
C                                                                               
          P(1) = CMPLX( -0.9098678,  1.8364514 )                        
          RTYPE(1) = 'CP'                                               
          P(2) = CMPLX( -1.3789032,  1.1915667 )                        
          RTYPE(2) = 'CP'                                               
          P(3) = CMPLX( -1.6120388,  0.5892445 )                        
          RTYPE(3) = 'CP'                                               
          P(4) = CMPLX( -1.6843682, 0.0 )                               
          RTYPE(4) = 'SP'                                               
C                                                                               
        ELSE IF (  IORD .EQ. 8 ) THEN                                   
C                                                                               
          P(1) = CMPLX( -0.8928710,  1.9983286 )                        
          RTYPE(1) = 'CP'                                               
          P(2) = CMPLX( -1.3738431,  1.3883585 )                        
          RTYPE(2) = 'CP'                                               
          P(3) = CMPLX( -1.6369417,  0.8227968 )                        
          RTYPE(3) = 'CP'                                               
          P(4) = CMPLX( -1.7574108,  0.2728679 )                        
          RTYPE(4) = 'CP'                                               
C                                                                               
        END IF                                                          
C                                                                               
        NSECTS = IORD - IORD/2                                          
C                                                                               
        DCVALUE = 1.0                                                   
C                                                                               
C  DONE                                                                         
C                                                                               
      RETURN                                                            
      END                                                               
