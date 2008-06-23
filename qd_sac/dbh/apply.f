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
C                                                               APPLY           
C  Subroutine to apply an iir filter to a data sequence.                        
C    The filter is assumed to be stored as second order sections.               
C    Filtering is in-place.                                                     
C    Zero-phase (forward and reverse) is an option.                             
C                                                                               
C  Input Arguments:                                                             
C  ----------------                                                             
C                                                                               
C    DATA                           Array containing data                       
C                                                                               
C    NSAMPS                         Number of data samples                      
C                                                                               
C    ZP                             Logical variable, true for                  
C                                     zero phase filtering, false               
C                                     for single pass filtering                 
C                                                                               
C    SN                             Numerator polynomials for second            
C                                     order sections.                           
C                                                                               
C    SD                             Denominator polynomials for second          
C                                     order sections.                           
C                                                                               
C    NSECTS                         Number of second-order sections             
C                                                                               
C  Output Arguments:                                                            
C  -----------------                                                            
C                                                                               
C    DATA                          Data array (same as input)                   
C                                                                               
C                                                                               
      SUBROUTINE APPLY( DATA, NSAMPS, ZP, SN, SD, NSECTS )              
C                                                                             
      IMPLICIT NONE

      REAL*4 SN(1), SD(1), DATA(1)
      INTEGER NSAMPS,NSECTS
      LOGICAL ZP    
                                      
      INTEGER JPTR,J,I
      REAL*4 X1,X2,Y1,Y2,B0,B1,B2,A1,A2,OUTPUT
                                                          
C                                                                               
        JPTR = 1                                                        
        DO    1 J = 1, NSECTS                                           
C                                                                               
          X1 = 0.0                                                      
          X2 = 0.0                                                      
          Y1 = 0.0                                                      
          Y2 = 0.0                                                      
          B0 = SN(JPTR)                                                 
          B1 = SN(JPTR+1)                                               
          B2 = SN(JPTR+2)                                               
          A1 = SD(JPTR+1)                                               
          A2 = SD(JPTR+2)                                               
C                                                                               
          DO    2 I = 1, NSAMPS                                         
C                                                                               
            OUTPUT = B0*DATA(I) + B1*X1 + B2*X2                         
            OUTPUT = OUTPUT - ( A1*Y1 + A2*Y2 )                         
            Y2 = Y1                                                     
            Y1 = OUTPUT                                                 
            X2 = X1                                                     
            X1 = DATA(I)                                                
            DATA(I) = OUTPUT                                            
C                                                                               
    2     CONTINUE                                                      
C                                                                               
          JPTR = JPTR + 3                                               
C                                                                               
    1   CONTINUE                                                        
C                                                                               
        IF (   ZP ) THEN                                                
C                                                                               
          JPTR = 1                                                      
          DO    3 J = 1, NSECTS                                         
C                                                                               
            X1 = 0.0                                                    
            X2 = 0.0                                                    
            Y1 = 0.0                                                    
            Y2 = 0.0                                                    
            B0 = SN(JPTR)                                               
            B1 = SN(JPTR+1)                                             
            B2 = SN(JPTR+2)                                             
            A1 = SD(JPTR+1)                                             
            A2 = SD(JPTR+2)                                             
C                                                                               
            DO    4 I = NSAMPS, 1, -1                                   
C                                                                               
              OUTPUT = B0*DATA(I) + B1*X1 + B2*X2                       
              OUTPUT = OUTPUT - ( A1*Y1 + A2*Y2 )                       
              Y2 = Y1                                                   
              Y1 = OUTPUT                                               
              X2 = X1                                                   
              X1 = DATA(I)                                              
              DATA(I) = OUTPUT                                          
C                                                                               
    4       CONTINUE                                                    
C                                                                               
            JPTR = JPTR + 3                                             
C                                                                               
    3     CONTINUE                                                      
C                                                                               
        END IF                                                          
C                                                                               
      RETURN                                                            
      END                                                               
