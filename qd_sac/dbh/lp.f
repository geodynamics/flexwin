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
C                                                    LP                         
C   Modification History:
C   020416: Changed SN and SD adjustable arrays to use 
C           "*" rather than "1". - wct
C
C                                                                               
C  Subroutine to generate second order section parameterization                 
C    from an pole-zero description for lowpass filters.                         
C                                                                               
C  Input Arguments:                                                             
C  ----------------                                                             
C                                                                               
C    P                       Array containing poles                             
C                                                                               
C    Z                       Array containing zeros                             
C                                                                               
C    RTYPE                   Character array containing root type information   
C                              (SP)  Single real pole or                        
C                              (CP)  Complex conjugate pole pair                
C                              (CPZ) Complex conjugate pole and zero pairs      
C                                                                               
C    DCVALUE                 Zero-frequency value of prototype filter           
C                                                                               
C    NSECTS                  Number of second-order sections                    
C                                                                               
C  Output Arguments:                                                            
C  -----------------                                                            
C                                                                               
C    SN                      Numerator polynomials for second order             
C                              sections.                                        
C                                                                               
C    SD                      Denominator polynomials for second order           
C                              sections.                                        
C                                                                               
C                                                                               
      SUBROUTINE LP( P, Z, RTYPE, DCVALUE, NSECTS, SN, SD )             
C                                                                               
        COMPLEX P(*), Z(*)                                              
        CHARACTER*3 RTYPE(*) 
        INTEGER NSECTS
        REAL*4 SN(*), SD(*), DCVALUE 

        INTEGER IPTR,I
        REAL*4 SCALE


C                                                                               
        IPTR = 1                                                        
        DO    1 I = 1, NSECTS                                           
C                                                                               
          IF (   RTYPE(I) .EQ. 'CPZ' ) THEN                             
C                                                                               
            SCALE = REAL( P(I) * CONJG( P(I) ) )                        
     &            / REAL( Z(I) * CONJG( Z(I) ) )                        
            SN( IPTR )     = REAL( Z(I) * CONJG( Z(I) ) ) * SCALE       
            SN( IPTR + 1 ) = -2. * REAL( Z(I) ) * SCALE                 
            SN( IPTR + 2 ) = 1. * SCALE                                 
            SD( IPTR )     = REAL( P(I) * CONJG( P(I) ) )               
            SD( IPTR + 1 ) = -2. * REAL( P(I) )                         
            SD( IPTR + 2 ) = 1.                                         
            IPTR = IPTR + 3                                             
C                                                                               
          ELSE IF (   RTYPE(I) .EQ. 'CP' ) THEN                         
C                                                                               
            SCALE = REAL( P(I) * CONJG( P(I) ) )                        
            SN( IPTR )     = SCALE                                      
            SN( IPTR + 1 ) = 0.                                         
            SN( IPTR + 2 ) = 0.                                         
            SD( IPTR )     = REAL( P(I) * CONJG( P(I) ) )               
            SD( IPTR + 1 ) = -2. * REAL( P(I) )                         
            SD( IPTR + 2 ) = 1.                                         
            IPTR = IPTR + 3                                             
C                                                                               
          ELSE IF (  RTYPE(I) .EQ. 'SP' ) THEN                          
C                                                                               
            SCALE = -REAL( P(I) )                                       
            SN( IPTR )     = SCALE                                      
            SN( IPTR + 1 ) = 0.                                         
            SN( IPTR + 2 ) = 0.                                         
            SD( IPTR )     = -REAL( P(I) )                              
            SD( IPTR + 1 ) = 1.                                         
            SD( IPTR + 2 ) = 0.                                         
            IPTR = IPTR + 3                                             
C                                                                               
          END IF                                                        
C                                                                               
    1   CONTINUE                                                        
C                                                                               
        SN(1) = DCVALUE * SN(1)                                         
        SN(2) = DCVALUE * SN(2)                                         
        SN(3) = DCVALUE * SN(3)                                         
                                                                        
C                                                                               
      RETURN                                                            
      END                                                               
                                                                        
                                                                        
                                                                        
