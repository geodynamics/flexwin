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
C                                                    CUTOFFS                    
C                                                                               
C  Subroutine to alter the cutoff of a filter.  Assumes that the                
C    filter is structured as second order sections.  Changes                    
C    the cutoffs of normalized lowpass and highpass filters through             
C    a simple polynomial transformation.                                        
C                                                                               
C  Input Arguments:                                                             
C  ----------------                                                             
C                                                                               
C    F                       New cutoff frequency                               
C                                                                               
C  Input/Output Arguments:                                                      
C  -----------------------                                                      
C                                                                               
C    SN                      Numerator polynomials for second order             
C                              sections.                                        
C                                                                               
C    SD                      Denominator polynomials for second order           
C                              sections.                                        
C                                                                               
C    NSECTS                  Number of second order sectionsects                
C                                                                               
C                                                                               
      SUBROUTINE CUTOFFS( SN, SD, NSECTS, F )                           
C                                       
        IMPLICIT NONE
        REAL*4 SN(1), SD(1), F
        INTEGER NSECTS
        
        REAL*4 SCALE
        INTEGER I,IPTR

C                                                                               
        SCALE = 2.*3.14159265*F                                         
C                                                                               
        IPTR = 1                                                        
        DO    1 I = 1, NSECTS                                           
C                                                                               
          SN( IPTR + 1 ) = SN( IPTR + 1 ) / SCALE                       
          SN( IPTR + 2 ) = SN( IPTR + 2 ) / (SCALE*SCALE)               
          SD( IPTR + 1 ) = SD( IPTR + 1 ) / SCALE                       
          SD( IPTR + 2 ) = SD( IPTR + 2 ) / (SCALE*SCALE)               
          IPTR = IPTR + 3                                               
C                                                                               
    1   CONTINUE                                                        
C                                                                               
      RETURN                                                            
      END                                                               
