C XAPIIR -- SUBROUTINE:   IIR FILTER DESIGN AND IMPLEMENTATION                  
C                                                                               
C  AUTHOR:  Dave Harris                                                         
C                                                                               
C  LAST MODIFIED:  September 12, 1990                                           
C                                                                               
C  ARGUMENTS:                                                                   
C  ----------                                                                   
C                                                                               
C    DATA           REAL ARRAY CONTAINING SEQUENCE TO BE FILTERED               
C                     ORIGINAL DATA DESTROYED, REPLACED BY FILTERED DATA        
C                                                                               
C    NSAMPS         NUMBER OF SAMPLES IN DATA                                   
C                                                                               
C                                                                               
C    APROTO         CHARACTER*8 VARIABLE, CONTAINS TYPE OF ANALOG               
C                     PROTOTYPE FILTER                                          
C                     '(BU)TTER  ' -- BUTTERWORTH FILTER                        
C                     '(BE)SSEL  ' -- BESSEL FILTER                             
C                     'C1      ' -- CHEBYSHEV TYPE I                            
C                     'C2      ' -- CHEBYSHEV TYPE II                           
C                                                                               
C    TRBNDW         TRANSITION BANDWIDTH AS FRACTION OF LOWPASS                 
C                   PROTOTYPE FILTER CUTOFF FREQUENCY.  USED                    
C                   ONLY BY CHEBYSHEV FILTERS.                                  
C                                                                               
C    A              ATTENUATION FACTOR.  EQUALS AMPLITUDE                       
C                   REACHED AT STOPBAND EDGE.  USED ONLY BY                     
C                   CHEBYSHEV FILTERS.                                          
C                                                                               
C    IORD           ORDER (#POLES) OF ANALOG PROTOTYPE                          
C                   NOT TO EXCEED 10 IN THIS CONFIGURATION.  4 - 5              
C                   SHOULD BE AMPLE.                                            
C                                                                               
C    TYPE           CHARACTER*8 VARIABLE CONTAINING FILTER TYPE                 
C                     'LP' -- LOW PASS                                          
C                     'HP' -- HIGH PASS                                         
C                     'BP' -- BAND PASS                                         
C                     'BR' -- BAND REJECT                                       
C                                                                               
C    FLO            LOW FREQUENCY CUTOFF OF FILTER (HERTZ)                      
C                   IGNORED IF TYPE = 'LP'                                      
C                                                                               
C    FHI            HIGH FREQUENCY CUTOFF OF FILTER (HERTZ)                     
C                   IGNORED IF TYPE = 'HP'                                      
C                                                                               
C    TS             SAMPLING INTERVAL (SECONDS)                                 
C                                                                               
C    PASSES           INTEGER VARIABLE CONTAINING THE NUMBER OF PASSES          
C                   1 -- FORWARD FILTERING ONLY                                 
C                   2 -- FORWARD AND REVERSE (I.E. ZERO PHASE) FILTERING        
C                                                                               
C                                                                               
C  SUBPROGRAMS REFERENCED:  BILIN2, BUROOTS, WARP, CUTOFFS, LPTHP, LPTBP,       
C    LP, LPTBR, BEROOTS, C1ROOTS, C2ROOTS, CHEBPARM, DESIGN, APPLY              
C                                                                               
      SUBROUTINE XAPIIR( DATA, NSAMPS, APROTO, TRBNDW, A, IORD,         
     +                   TYPE, FLO, FHI, TS, PASSES )                   
C                                                                               
      IMPLICIT NONE
C                                                                               
        REAL*4  DATA(1)                                               
        CHARACTER*8  TYPE, APROTO                                        
        INTEGER  NSAMPS, PASSES, IORD                                 
        REAL*4  TRBNDW, A, FLO, FHI, TS
        
        REAL*4  SN(30), SD(30)                  
        LOGICAL ZP                  
        INTEGER  NSECTS

C CHECK IF FLO IS SMALLER THAN FHI AND BOTH POSITIVE
        IF (FLO .LE. 0 .OR. FHI .LE. 0 .OR. FLO .GE. FHI)
     &       STOP 'IN XAPIIR SUBROUTINE, FLO > 0, FHI > 0 AND FLO < FHI 
     &            IS NOT SATISFIED'


C                                                                               
C  Filter designed                                                              
C                                                                               
        CALL DESIGN( IORD, TYPE(1:2), APROTO(1:2), A, TRBNDW,           
     &               FLO, FHI, TS, SN, SD, NSECTS )                     
C                                                                               
C  Filter data                                                                  
C                                                                               
        IF (   PASSES .EQ. 1 ) THEN                                     
          ZP = .FALSE.                                                  
        ELSE                                                            
          ZP = .TRUE.                                                   
        END IF                                                          
        CALL APPLY( DATA, NSAMPS, ZP, SN, SD, NSECTS )                  
C                                                                               
      RETURN                                                            
      END                                                               
