
#include <stdio.h>
#include "hec.h"

/*********************************************************************/

/* cross correlation function */

int xcorr(const float *data, int ndata,
	  const float *syn, int nsyn,
	  float *corr, int *nshift)
     // nshift from 1 - nsynto ndata - 1

{
  int i,j,jmin,jmax,shift,ncorr;
 
  if ( ndata <=0 || nsyn <=0 ) {
    fprintf(stderr,"No data or syn is read in ...\n");
    return 0;
  }
  ncorr = ndata + nsyn -1;
  for ( i=0; i<ncorr; i++ ) { nshift[i] = i - nsyn + 1; }
  for ( i=0; i<ncorr; i++) {
    shift = nshift[i];
    jmin = 1 > 1-shift ? 1 : 1-shift; 
    jmax = nsyn < ndata-shift ? nsyn : ndata-shift;
    corr[i] = 0.;
    for (j = jmin - 1; j < jmax; j++)
      corr[i] += syn[j] * data[j+shift];
  }
  return ncorr;

}
 

