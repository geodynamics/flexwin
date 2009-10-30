#!/usr/bin/python
# similar to Carl's prepare_meas_all.pl script
# Qinya Liu, Oct 2009, UofT
import os,sys,glob

if (len(sys.argv) != 3):
  print "write_flexwin_out.py measure_dir out_filename"; exit()

dir=sys.argv[1]; out=sys.argv[2]
if (not os.path.isdir(dir)):
  print 'check if '+dir+' exists or not'; exit()

output=''
files=glob.glob(dir+'/*mt*');
nfiles=len(files);
for file in files:
  output=output+''.join(os.popen('cat '+file).readlines())

output=str(nfiles)+'\n'+output
f=open(out, 'w')
f.write(output)
f.close()

