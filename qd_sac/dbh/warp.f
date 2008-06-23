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
C WARP -- FUNCTION, APPLIES TANGENT FREQUENCY WARPING TO COMPENSATE             
C         FOR BILINEAR ANALOG -> DIGITAL TRANSFORMATION                         
C                                                                               
C ARGUMENTS:                                                                    
C ----------                                                                    
C                                                                               
C      F       ORIGINAL DESIGN FREQUENCY SPECIFICATION (HERTZ)                  
C      TS      SAMPLING INTERVAL (SECONDS)                                      
C                                                                               
C  LAST MODIFIED:  SEPTEMBER 20, 1990                                           
C                                                                               
      REAL*4  FUNCTION WARP( F , TS )                                      
C                                                                               
        IMPLICIT NONE

        REAL*4 F,TS
        REAL*4 TWOPI,ANGLE

        TWOPI = 6.2831853                                               
        ANGLE = TWOPI*F*TS/2.                                           
        WARP = 2.*TAN(ANGLE)/TS                                         
        WARP = WARP/TWOPI                                               
C                                                                               
      RETURN                                                            
      END                                                               
