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
C                                                    LPTHP                      
C                                                                               
C  Subroutine to convert a lowpass filter to a highpass filter via              
C    an analog polynomial transformation.  The lowpass filter is                
C    described in terms of its poles and zeroes (as input to this routine).     
C    The output consists of the parameters for second order sections.           
C                                                                               
C  Input Arguments:                                                             
C  ----------------                                                             
C                                                                               
C    P                       Array containing poles                             
C                                                                               
C    Z                       Array containing zeroes                            
C                                                                               
C    RTYPE                   Character array containing root type information   
C                              (SP) single real pole or                         
C                              (CP)  complex conjugate pair                     
C                              (CPZ) complex pole/zero pairs                    
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
      SUBROUTINE LPTHP( P, Z, RTYPE, DCVALUE, NSECTS, SN, SD )          
C                                                                               
        IMPLICIT NONE
        COMPLEX P(*), Z(*)                                              
        CHARACTER*3 RTYPE(*)                                            
        REAL*4 SN(*), SD(*), DCVALUE
        INTEGER NSECTS

        INTEGER I,IPTR
        REAL*4 SCALE
C                                                                               
        IPTR = 1                                                        
        DO    1 I = 1, NSECTS                                           
C                                                                               
          IF (     RTYPE(I) .EQ. 'CPZ' ) THEN                           
C                                                                               
            SCALE = REAL( P(I) * CONJG( P(I) ) )                        
     &            / REAL( Z(I) * CONJG( Z(I) ) )                        
            SN( IPTR )     = 1.  *  SCALE                               
            SN( IPTR + 1 ) = -2. * REAL( Z(I) )  *  SCALE               
            SN( IPTR + 2 ) = REAL( Z(I) * CONJG( Z(I) ) )  *  SCALE     
            SD( IPTR )     = 1.                                         
            SD( IPTR + 1 ) = -2. * REAL( P(I) )                         
            SD( IPTR + 2 ) = REAL( P(I) * CONJG( P(I) ) )               
            IPTR = IPTR + 3                                             
C                                                                               
          ELSE IF (   RTYPE(I) .EQ. 'CP' ) THEN                         
C                                                                               
            SCALE = REAL( P(I) * CONJG( P(I) ) )                        
            SN( IPTR )     = 0.                                         
            SN( IPTR + 1 ) = 0.                                         
            SN( IPTR + 2 ) = SCALE                                      
            SD( IPTR )     = 1.                                         
            SD( IPTR + 1 ) = -2. * REAL( P(I) )                         
            SD( IPTR + 2 ) = REAL( P(I) * CONJG( P(I) ) )               
            IPTR = IPTR + 3                                             
C                                                                               
          ELSE IF (  RTYPE(I) .EQ. 'SP' ) THEN                          
C                                                                               
            SCALE = -REAL( P(I) )                                       
            SN( IPTR )     = 0.                                         
            SN( IPTR + 1 ) = SCALE                                      
            SN( IPTR + 2 ) = 0.                                         
            SD( IPTR )     = 1.                                         
            SD( IPTR + 1 ) = -REAL( P(I) )                              
            SD( IPTR + 2 ) = 0.                                         
            IPTR = IPTR + 3                                             
C                                                                               
          END IF                                                        
C                                                                               
    1   CONTINUE                                                        
C                                                                               
        SN(1) = SN(1) * DCVALUE                                         
        SN(2) = SN(2) * DCVALUE                                         
        SN(3) = SN(3) * DCVALUE                                         
C                                                                               
      RETURN                                                            
      END                                                               
