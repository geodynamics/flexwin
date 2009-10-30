#!/usr/bin/python
# Similar to Carl's plot_windows_all.pl script
# Qinya Liu, Oct 2009, UofT
# plots are sort by distance and then components

import sys,os

if (len(sys.argv) != 2):
  print "plot_flexwin.py measure_dir(MEASURE)"; exit()

dir=sys.argv[1]
if not os.path.isdir(dir):
  print "no such dir "+dir; exit()
script1='scripts/plot_seismos_gmt.sh'
script2='scripts/extract_event_windowing_stats.sh'
if not os.path.isfile(script1) or not os.path.isfile(script2):
  print 'no '+script1+' or '+script2; exit()

if (os.system(script2+' '+dir+' > /dev/null') != 0):
  print 'Error executing '+ script2; exit()

ps=dir+'/event_winstats.pdf'+' '+dir+'/event_recordsection.pdf'

for basename in os.popen('grep DDG '+dir+"/*.info | awk '{print $1,$4}'| sort -k 2 -g | awk '{print $1}' | sed 's/\.info:#//g'").readlines():
  input = basename.rstrip()  
  if (os.system(script1+' '+input) != 0):
    print "Error plotting individual seismograms"; exit()
  ps = ps + ' '+input+'.seis.pdf'

if (os.system('pdcat -r '+ps+' flexwin_seis.pdf') != 0):
  print "Error concatenate all seismogram plots"; exit()


