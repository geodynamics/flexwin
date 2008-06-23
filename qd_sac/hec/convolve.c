#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "dcomplex.h"
#include "hec.h"


/*******************************************************************/

int convolve(const float *data, int ndata,
	      const float *syn,  int nsyn,
	      float *conv)

{

  int ncorr,n_max,i;
  dcomplex *cdata,*csyn,*ccorr;

  if (ndata <=0 || nsyn <=0) {
    fprintf(stderr,"No data or syn is read in ...\n");
    return -1;
  }
  
  ncorr = ndata+nsyn-1; // length of correlation time series
  n_max = nextpow2(ncorr); // closest 2 power 

  // dynamic allocate array to avoid defining upper limit of the length
  cdata = (dcomplex *) malloc(n_max * sizeof(dcomplex));
  csyn = (dcomplex *) malloc(n_max * sizeof(dcomplex));
  ccorr = (dcomplex *) malloc(n_max * sizeof(dcomplex));

  // set complex data and syn array
  for (i=0; i<ndata; i++) {cdata[i].re = (double) data[i];  cdata[i].im = 0.;}
  for (i=ndata; i<n_max; i++) cdata[i].re = cdata[i].im = 0.;

  for (i=0; i<nsyn; i++) {csyn[i].re = (double) syn[i]; csyn[i].im = 0.;}
  for (i=nsyn; i<n_max; i++) csyn[i].re = csyn[i].im = 0.;

  // fft both complex data and syn array
  cfft(cdata,n_max,1);
  cfft(csyn,n_max,1);

  // in frequency domain, calculate the fft of correlation
  for (i=0;i<n_max;i++) ccorr[i] = dcmult(cdata[i],csyn[i]);

  // fft back to get the correlation time series
  cfft(ccorr,n_max,-1);
  for (i=0;i<ncorr;i++) conv[i] = (float) (ccorr[i].re/n_max);
  
  free(cdata); free(csyn); free(ccorr);
  return ncorr;

}



