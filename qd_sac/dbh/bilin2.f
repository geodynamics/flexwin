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
C  Transforms an analog filter to a digital filter via the bilinear transformati
C    Assumes both are stored as second order sections.  The transformation is   
C    done in-place.                                                             
C                                                                               
C  Input Arguments:                                                             
C  ----------------                                                             
C                                                                               
C    SN                   Array containing numerator polynomial coefficients for
C                           second order sections.  Packed head-to-tail.        
C                                                                               
C    SD                   Array containing denominator polynomial coefficients f
C                           second order sections.  Packed head-to-tail.        
C                                                                               
C    NSECTS               Number of second order sections.                      
C                                                                               
C                                                                               
      SUBROUTINE BILIN2( SN, SD, NSECTS )                               
C 
        IMPLICIT NONE
        REAL*4 SN(1), SD(1)
        INTEGER NSECTS

        INTEGER IPTR,I
        REAL*4 A0,A1,A2,SCALE

C                                                                               
        IPTR = 1                                                        
        DO    1 I = 1, NSECTS                                           
C                                                                               
          A0 = SD(IPTR)                                                 
          A1 = SD(IPTR+1)                                               
          A2 = SD(IPTR+2)                                               
C                                                                               
          SCALE = A2 + A1 + A0                                          
          SD(IPTR)   = 1.                                               
          SD(IPTR+1) = (2.*(A0 - A2)) / SCALE                           
          SD(IPTR+2) = (A2 - A1 + A0) / SCALE                           
C                                                                               
          A0 = SN(IPTR)                                                 
          A1 = SN(IPTR+1)                                               
          A2 = SN(IPTR+2)                                               
C                                                                               
          SN(IPTR)   = (A2 + A1 + A0) / SCALE                           
          SN(IPTR+1) = (2.*(A0 - A2)) / SCALE                           
          SN(IPTR+2) = (A2 - A1 + A0) / SCALE                           
C                                                                               
          IPTR = IPTR + 3                                               
C                                                                               
    1   CONTINUE                                                        
C                                                                               
      RETURN                                                            
      END                                                               
