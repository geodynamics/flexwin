#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "dcomplex.h"
#include "hec.h"
/**********************************************************

 *   crosscorr 

  Purpose: uses fft to compute the cross correlation of 
           two time series.  

  Input:  time series and their length (data,ndata,syn,nsyn)
 
  Output: correlation time series (corr)
  
  Return: the index of the zero shift of syn in corr array

  Remark: 1) Length of the correlation time series is assumed
          to be ndata + nsyn - 1.  2) corr[0..ndata+nsyn-1] 
          corresponds to syn time series shift from 1 - nsyn 
          to ndata - 1 

  Modifications:

************************************************************/

int crosscorr(const float *data, int ndata,
	      const float *syn,  int nsyn,
	      float *corr)

{

  int ncorr,n_max,i;
  dcomplex *cdata,*csyn,*ccorr;
  float *corr_temp;

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
  corr_temp = (float *) malloc(n_max * sizeof(float));

  // set complex data and syn array
  for (i=0; i<ndata; i++) {cdata[i].re = (double) data[i];  cdata[i].im = 0.;}
  for (i=ndata; i<n_max; i++) cdata[i].re = cdata[i].im = 0.;

  for (i=0; i<nsyn; i++) {csyn[i].re = (double) syn[i]; csyn[i].im = 0.;}
  for (i=nsyn; i<n_max; i++) csyn[i].re = csyn[i].im = 0.;

  // fft both complex data and syn array
  cfft(cdata,n_max,1);
  cfft(csyn,n_max,1);

  // in frequency domain, calculate the fft of correlation
  for (i=0;i<n_max;i++) ccorr[i] = dcmult(cdata[i],dconj(csyn[i]));

  // fft back to get the correlation time series
  cfft(ccorr,n_max,-1);
  for (i=0;i<n_max;i++) corr_temp[i] = (float) (ccorr[i].re/n_max);
  
  // shift the correlation time series to the convention adopted
  for (i=0;i<nsyn-1;i++) corr[i] = corr_temp[i+n_max-nsyn+1];
  for (i=nsyn-1;i<ncorr;i++) corr[i] = corr_temp[i-nsyn+1];

  free(cdata); free(csyn); free(ccorr); free(corr_temp);

  return nsyn-1;

}

/**********************************************************

 *   autocorr 

  Purpose: uses fft to compute the auto correlation of 
           a time series.

  Input:  time series and its length (data,ndata,syn,nsyn)
 
  Output: auto correlation time series (corr)
  
  Return: the index of the zero shift in corr array

  Remark: 1) Length of the correlation time series is assumed
          to be 2 * ndata - 1.  2) corr[0..2*ndata-1] 
          corresponds to syn time series shift from 1 - ndata 
          to ndata - 1, and is symmetric.

  Modifications:

************************************************************/

int autocorr(const float *data, int ndata,
	     float *corr)

{

  int ncorr,n_max,i;
  dcomplex *cdata,*ccorr;
  double ctemp;
  float  *corr_temp;

  if (ndata <=0) {
    fprintf(stderr,"No data or syn is read in ...\n");
    return -1;
  }
  
  ncorr = ndata * 2 - 1;
  n_max = nextpow2(ncorr);

  cdata = (dcomplex *) malloc(n_max * sizeof(dcomplex));
  ccorr = (dcomplex *) malloc(n_max * sizeof(dcomplex));
  corr_temp = (float *) malloc(n_max * sizeof(float));

  for (i=0; i<ndata; i++) { cdata[i].re = (double) data[i];  cdata[i].im = 0.;}
  for (i=ndata; i<n_max; i++) cdata[i].re = cdata[i].im = 0.;

  cfft(cdata,n_max,1);

  for (i=0;i<n_max;i++) {
    ctemp = dmodu(cdata[i]);
    ccorr[i].re = ctemp * ctemp;
    ccorr[i].im = 0;
  }

  cfft(ccorr,n_max,-1);

  for (i=0;i<n_max;i++) corr_temp[i] = (float) (ccorr[i].re/n_max);
  
  for (i=0;i<ndata-1;i++) corr[i] = corr_temp[i+n_max-ndata+1];
  for (i=ndata-1;i<ncorr;i++) corr[i] = corr_temp[i-ndata+1];

  free(cdata); free(ccorr); free(corr_temp);
  return ndata-1;

}


/**********************************************************

 *   autocorr2

  Purpose: uses fft to compute the auto correlation of 
           a time series.  

  Input:  time serie and its length (data,ndata)
 
  Output: auto correlation time series (corr)
  
  Return: 0 if success
          -1 otherwise

  Remark: 1) Length of the auto correlation time series is assumed
          to be ndata.  2) corr[0..ndata-1] corresponds shift from 
          0 to ndata - 1 

  Modifications:

************************************************************/


int autocorr2(const float *data, int ndata,
	     float *corr)

{

  int ncorr,n_max,i;
  dcomplex *cdata,*ccorr;
  float *corr_temp;
  double ctemp;

  if (ndata <=0) {
    fprintf(stderr,"No data or syn is read in ...\n");
    return -1;
  }
  
  ncorr = ndata * 2 - 1;
  n_max = nextpow2(ncorr);

  cdata = (dcomplex *) malloc(n_max * sizeof(dcomplex));
  ccorr = (dcomplex *) malloc(n_max * sizeof(dcomplex));
  corr_temp = (float *) malloc(n_max * sizeof(float));
  
  if (cdata == NULL || ccorr == NULL || corr_temp == NULL) {
    fprintf(stderr,"Error dynamic allocate array\n");
    return -1;}
  
  for (i=0; i<ndata; i++) { cdata[i].re = (double) data[i];  cdata[i].im = 0.;}
  for (i=ndata; i<n_max; i++) cdata[i].re = cdata[i].im = 0.;

  cfft(cdata,n_max,1);

  for (i=0;i<n_max;i++) {
    ctemp = dmodu(cdata[i]);
    ccorr[i].re = ctemp * ctemp;
    ccorr[i].im = 0;
  }

  cfft(ccorr,n_max,-1);

  for (i=0;i<n_max;i++) corr_temp[i] = (float) (ccorr[i].re/n_max);
  
  for (i=0;i<ndata-1;i++) corr[i] = corr_temp[i];


  free(cdata); free(ccorr); free(corr_temp);
  return 0;

}



