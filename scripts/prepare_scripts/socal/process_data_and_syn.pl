#!/usr/bin/perl -w

#==========================================================
#
#  Carl Tape
#  24-July-2007
#  process_data_and_syn.pl
#
#  This script processes data and 3D-Socal-SEM synthetics for Southern California.
#
#  INPUT:
#    CMT_list  list of event ID labels in a file
#    dir_syn   directory for synthetics
#    dir_dat   directory for data
#    stafile   STATIONS file ("none" for default)
#    hdur      shortest period for filtering data and synthetics
#
#    syn_ext   extension for processed synthetics
#    dat_ext   extension for processed data
#    Trange    band-pass filter
#
#  ORDER OF OPERATIONS:
#    ~/UTILS/process_data_and_syn.pl 1 m07 1 0 d d 20 6/40 PROCESSED    # data, initial pre-processing
#    ~/UTILS/process_data_and_syn.pl 1 m07 0 1 d d 20 6/40 PROCESSED    # syn, initial pre-processing
#    ~/UTILS/process_data_and_syn.pl 2 m07 1 1 d d 20 6/40 PROCESSED    # both, create cut files
#    ~/UTILS/process_data_and_syn.pl 3 m07 1 0 d d 20 6/40 PROCESSED    # data, execute cut file
#    ~/UTILS/process_data_and_syn.pl 3 m07 0 1 d d 20 6/40 PROCESSED    # syn, execute cut file
#
#    ~/UTILS/process_data_and_syn.pl 4 m07 1 0 d d 20 6/40 PROCESSED    # data, bandpass T=6-40
#    ~/UTILS/process_data_and_syn.pl 4 m07 0 1 d d 20 6/40 PROCESSED    # syn, bandpass T=6-40
#
#    ~/UTILS/process_data_and_syn.pl 4 m07 1 0 d d 20 2/40 PROCESSED    # data, bandpass T=2-40
#    ~/UTILS/process_data_and_syn.pl 4 m07 0 1 d d 20 2/40 PROCESSED    # syn, bandpass T=2-40
#
#==========================================================

if (@ARGV < 9) {die("Usage: process_data_and_syn.pl iprocess smodel idata isyn syn_ext dat_ext sps Tmin/Tmax pdir\n")}
($iprocess,$smodel,$idata,$isyn,$syn_ext,$dat_ext,$sps,$Trange,$pdir) = @ARGV;

#$smodel = "m05";   # KEY: model iteration index
$iexecute = 0;
$ilist = 1;

$iprocess0 = 0;

# THESE MUST BE DONE IN SEQUENTIAL ORDER
#$iprocess1 = 0;    # only done ONCE, no matter how many band-pass filters you use
#$iprocess2 = 1;    # cut records and pad zeros (and bandpass, if iprocess3=1)
#$iprocess3 = 0;    # bandpass filter (iprocess2=1 also)

#$Lrange = "-l -40/220";
#$Lrange = " ";

# USER PARAMETERS
$tfac = 1.0;      # factor to extend lengths of records (should be > 1.0)
$itest = 0;       # test directories or not
$bmin = -40;      # minimum time before origin time
$syn_suffix0 = "semd.sac";                  # suffix for synthetic files
$syn_suffix = "${syn_suffix0}.${syn_ext}";
$dat_suffix0 = "sac";                       # suffix for data files
$dat_suffix = "${dat_suffix0}.${dat_ext}"; 

# directories
#$CMT_list = "/net/sierra/raid1/carltape/socal/socal_3D/SYN/model_${smodel}";
$dir_source = "/net/sierra/raid1/carltape/results/SOURCES/socal_9";
$dirCMT    = "${dir_source}/v9_files";
$CMT_list  = "${dir_source}/EIDs_only_eid";
$dirdat0    = "/net/sierra/raid1/carltape/socal/socal_3D/DATA/FINAL";
$dirsyn0    = "/net/sierra/raid1/carltape/socal/socal_3D/SYN/model_${smodel}";
#$dirsyn0 = "/net/sierra/raid1/carltape/socal/socal_3D/SYN/model_pre_${smodel}";

# check if the STATIONS file exists
#$stafile = "/net/denali/home2/carltape/gmt/stations/seismic/Matlab_output/STATIONS";
$stafile = "/net/denali/home2/carltape/gmt/stations/seismic/Matlab_output/STATIONS_CALIFORNIA_TOMO_INNER_specfem";
#$stafile = "/net/denali/home2/carltape/gmt/stations/seismic/Matlab_output/STATIONS_CALIFORNIA_TOMO_OUTER_specfem";
if (not -f $stafile) {print "\n check if $stafile exists -- we will use the default"; $stafile = "none";}

# period range
($Tmin,$Tmax) = split("/",$Trange);
$sTmin = sprintf("T%3.3i",$Tmin);
$sTmax = sprintf("T%3.3i",$Tmax);
$Ttag = "${sTmin}_${sTmax}";
$pdirbpass = "${pdir}_${Ttag}";

# grab all the CMT solution files or read in the list of event IDs
if($ilist == 1) {
  open(IN,"${CMT_list}"); @cmtfiles = <IN>; close(IN);
} else {
  @cmtfiles = glob("$dirCMT/CMTSOLUTION*");
}
$ncmt = @cmtfiles;

print "\n $dirCMT \n $dirsyn0 \n $dirdat0\n";
print "\n $ncmt CMTSOLUTION files\n";
if($ncmt == 0) {die("\n No CMTSOLUTION files")}

#$ncmt = 1;   # testing
if($ilist == 1) {
  for ($ievent = 1; $ievent <= $ncmt; $ievent++) {
    $cmtfile = $cmtfiles[$ievent-1]; chomp($cmtfile);
    $eid = $cmtfile;
    #$file0 = `basename $cmtfile`; ($junk,$eid) = split("_",$file0); chomp($eid);
    print "\n $ievent, Event $eid";
  }
}
#die("testing");

# write the C-shell script to file
if($idata==1 && $isyn==1) {
   $cshfile = "process_data_and_syn.csh";
} elsif($idata==1 && $isyn==0) {
   $cshfile = "process_data.csh";
} elsif($idata==0 && $isyn==1) {
   $cshfile = "process_syn.csh";
} else {
   die("check idata and isyn\n");
}
print "\nWriting to $cshfile ...\n";
open(CSH,">$cshfile");

if($iprocess==0) {
  $sfile = "nprocess_syn";
  open(SYN,">$sfile");
}

$imin = 1; $imax = $ncmt;  # default
#$imin = 101; $imax = $ncmt;
#$imin = 204; $imax = $imin;

#----------------------------------------------------------------------

#foreach $file (@cmtfiles) {
#for ($ievent = 1; $ievent <= $ncmt; $ievent++) {
for ($ievent = $imin; $ievent <= $imax; $ievent++) {

  # get the event ID
  if ($ilist == 1) {
    $eid = $cmtfiles[$ievent-1]; chomp($eid);
    $cmtfile = "$dirCMT/CMTSOLUTION_$eid";

  } else {
    $cmtfile = $cmtfiles[$ievent-1];
    $file0 = `basename $cmtfile`; ($junk,$eid) = split("_",$file0); chomp($eid);
  }
  print "$ievent, $imax, Event $eid\n";
  print CSH "echo $ievent, $imax, Event $eid\n";

  # data and synthetics directories
  $dirsyn = "${dirsyn0}/${eid}";
  $dirdat = "${dirdat0}/${eid}";
  $dirdat_pro_1 = "${dirdat0}/${eid}/$pdir";
  $dirsyn_pro_1 = "${dirsyn0}/${eid}/$pdir";
  $dirdat_pro_2 = "${dirdat_pro_1}/$pdirbpass";
  $dirsyn_pro_2 = "${dirsyn_pro_1}/$pdirbpass";

  # cut times files
  $cutfile_dat      = "$dirdat/${eid}_dat_cut";
  $cutfile_dat_done = "${cutfile_dat}_done";
  $cutfile_syn      = "$dirdat/${eid}_syn_cut";       # note: data directory
  $cutfile_syn_done = "$dirsyn/${eid}_syn_cut_done";  # note: syn directory

  # optional -- delete pre-processed directories
  #print CSH "rm -rf $dirsyn/PRO*\n";
  #print CSH "rm -rf $dirdat/PRO*\n";

  #----------------------------------------------------------------------
  # PROCESSING PART 0: check the number of processed synthetic files for each event

  if ($iprocess == 0) {
     if(-e ${dirsyn_pro_1}) {
       ($nfile,undef,undef) = split(" ",`ls -1 ${dirsyn_pro_1}/* | wc`);
       print SYN "$eid $nfile\n";
     }
  }

  #----------------------------------------------------------------------
  # PROCESSING PART 1: assign SAC headers, interpolate, and pick P and S arrivals (based on a 1D socal model)

  if ($iprocess == 1) {

    # synthetics -- this will convolve with the source half-duration (prior to interpolating)
    if ($isyn == 1) {
      if (-e $dirsyn) {
	if (not -e ${dirsyn_pro_1}) {
	  print CSH "cd $dirsyn\n";
          #print CSH "mv $pdir ${pdir}_OLD\n";
	  #print CSH "\\rm -rf $pdir\n";
	  print CSH "process_trinet_syn_new.pl -S -m $cmtfile -h -a $stafile -s $sps -p -d $pdir -x ${syn_ext} *.${syn_suffix0} \n";
	} else {
	  print "dir ${dirsyn_pro_1} already exists\n";
	}
      } else {
	print "$dirsyn does not exist\n";
      }
    }	  # isyn

    # data
    if ($idata == 1) {
      if (-e $dirdat) {
	if (not -e ${dirdat_pro_1}) {
	print CSH "cd $dirdat\n";
        #print CSH "mv $pdir ${pdir}_OLD\n";
	#print CSH "\\rm -rf $pdir; mkdir $pdir\n";
	print CSH "process_cal_data.pl -m $cmtfile -p -s $sps -d $pdir -x ${dat_ext} *.${dat_suffix0}\n";
	} else {
	  print "dir ${dirdat_pro_1} already exists\n";
	}
      } else {
	print "$dirdat does not exist\n";
      }
    }	  # idata

  }  # iprocess = 1

  #----------------------------------------------------------------------
  # PROCESSING PART 2: getting the cut times for the records

  if ($iprocess == 2) {

    # BOTH the INITIALLY processed synthetics and data directories must exist,
    # even if you only want to process synthetics.

    if ( (not -e ${dirdat_pro_1}) || (not -e ${dirsyn_pro_1}) ) {
      print "--> dirdat ${dirdat_pro_1} and dirsyn ${dirsyn_pro_1} do not both exist\n";

    } elsif ( ((-f $cutfile_syn) || (-f $cutfile_syn_done)) || ((-f $cutfile_dat) || (-f $cutfile_dat_done)) ) {

      if (-f $cutfile_syn) {
	print "cutfile_syn ${cutfile_syn} already exists\n";
      }
      if (-f $cutfile_syn_done) {
	print "cutfile_syn_done ${cutfile_syn_done} already exists\n";
      }
      if (-f $cutfile_dat) {
	print "cutfile_dat ${cutfile_dat} already exists\n";
      }
      if (-f $cutfile_dat_done) {
	print "cutfile_dat_done ${cutfile_dat_done} already exists\n";
      }
      print "--> you are probably ready for cutting or bandpassing...\n";

    } else {

      print "\nWriting to cutfiles ...\n";
      open(CUTDAT,">${cutfile_dat}");
      open(CUTSYN,">${cutfile_syn}");

      # grab all DATA files
      @files = glob("${dirdat_pro_1}/*");
      $nfile = @files;
      print "\n $nfile data files to line up with synthetics\n";

      foreach $datfile (@files) { 
	# read the sac headers -- network, station, component
	(undef,$net,$sta,$chan) = split(" ",`saclst knetwk kstnm kcmpnm f $datfile`);
	$comp = `echo $chan | awk '{print substr(\$1,3,1)}'`;
	chomp($comp);

	# synthetics are always BH_ component
	$synfile = "${dirsyn_pro_1}/${sta}.${net}.BH${comp}.${syn_suffix}";

	# if the synthetic file exists, then go on
	if (-f $synfile) {
          # only list files that are pairs
          # only base name is used for syn file
          $synfile_base = `basename $synfile`; chomp($synfile_base);
	  print "$datfile $synfile_base\n";

	  # get info on data and synthetics
	  (undef,$bd,$ed,$deltad,$nptd) = split(" ",`saclst b e delta npts f $datfile`);
	  (undef,$bs,$es,$deltas,$npts) = split(" ",`saclst b e delta npts f $synfile`);
	  $tlend = $ed - $bd;
	  $tlens = $es - $bs;
    
	  # dt should be the same for both records ALREADY
	  if (log($deltad/$deltas) > 0.01) {
	    print "$datfile $synfile\n";
	    print "DT values are not close enough: $deltad, $deltas\n";
	    die("fix the DT values\n");
	  } else {
	    $dt = $deltad;
	  }

	  # determine the cut for the records
	  # b = earliest start time
	  # e = earliest end time, multiplied by some factor
	  if ($bd < $bs) {
	    $b0 = $bd;
	  } else {
	    $b0 = $bs;
	  }
	  if ($b0 < $bmin) {
	    $b0 = $bmin;
	  }
	  if ($ed < $es) {
	    $e0 = $ed;
	  } else {
	    $e0 = $es;
	  }

          # avoid events 14263716 and 14179292
          # --> adjust the simulation times, rather than the cut times
          #if($eid == 14179288 || $eid == 14263712) {
          #   $e0 = 120;
          #}

	  $b = $b0;
	  $tlen0 = $e0 - $b;
	  $tlen = $tfac * $tlen0; # extend record length (if desired)
	  $e = $b0 + $tlen;
	  $npt = int( ($e-$b)/$dt );

	  #print CUT "$datfile $synfile $b $e $npt $dt\n";
	  print CUTDAT "$datfile $b $e $npt $dt\n";
	  print CUTSYN "$synfile_base $b $e $npt $dt\n";

	  if (0==1) {
	    print "\n Data : $bd $ed $deltad $nptd -- $tlend";
	    print "\n Syn  : $bs $es $deltas $npts -- $tlens";
	    print "\n b0, e0, tlen0 : $b0, $e0, $tlen0 ";
	    print "\n   b : $bd, $bs, $b ";
	    print "\n   e : $ed, $es, $e ";
	    print "\n npt : $nptd, $npts, $npt ";
	    print "\n $tlen = $tfac * ($e0 - $b)";
	    print "\n $e = $b0 + $tlen \n";
	  }
	}			# if synfile exists
      }				# for all data files
      print "\n Done making cutfile $cutfile_dat\n";
      print "\n Done making cutfile $cutfile_syn\n";
      close(CUTDAT);
      close(CUTSYN);
 
    }				# dirdat_pro_1 and dirsyn_pro_1 exist
  }				# iprocess=2

  #----------------------------------------------------------------------
  # PROCESSING PART 3: cutting records and padding zeros

  if ($iprocess == 3) {

    if ($idata == 1) {
      if (-e ${dirdat_pro_2}) {
	print "--> dirdat ${dirdat_pro_2} already exists\n";

      } else {
	if (-f $cutfile_dat_done) {
	  print "cutfile_dat_done ${cutfile_dat_done} already exists\n";

	} else {

	  if (not -f $cutfile_dat) {
	    print "cutfile_dat $cutfile_dat does not exist -- try iprocess = 2\n";

	  } else {

	    # read cut file
	    open(IN,"${cutfile_dat}"); @lines = <IN>; close(IN); $nlines = @lines;

	    $sacfile = "sacdat.mac";
	    `echo echo on > $sacfile`;
	    `echo readerr badfile fatal >> $sacfile`;

	    for ($j = 1; $j <= $nlines; $j++) {

	      $line = $lines[$j-1]; chomp($line);
	      ($datfile,$b,$e,$npt,$dt) = split(" ",$line);
	      print "$j out of $nlines -- $datfile\n";
	      #print "-- $datfile -- $synfile -- $b -- $e -- $npt -- $dt -- \n";

	      # cut records and fill zeros
	      `echo r $datfile >> $sacfile`;
	      `echo cuterr fillz >> $sacfile`;
	      `echo "cut $b n $npt" >> $sacfile`;
	      `echo r $datfile >> $sacfile`;
	      `echo cut off >> $sacfile`;
	      `echo w over >> $sacfile`;
	    } 
	    `echo quit >> $sacfile`;

	    # KEY: execute SAC command
	    `sac $sacfile`;
	    `sleep 5s`;
	    `rm $sacfile`;
	    print "\n Done cutting pre-processed data files\n";

	    # rename cut file in data directory
	    `mv ${cutfile_dat} ${cutfile_dat_done}`;

	  }			# cutfile exist
	}			# cutfile_done exist
      }				# bandpass dir exist
    }				# idata

    #------------------

    if ($isyn == 1) {
      if ( (-e ${dirsyn_pro_2}) || (not -e ${dirsyn_pro_1}) ) {
        if ( -e ${dirsyn_pro_2}) {print "--> dirsyn ${dirsyn_pro_2} already exists\n";}
        if ( not -e ${dirsyn_pro_1} ) {print "--> dirsyn ${dirsyn_pro_1} does not exist\n";}

      } else {
	if (-f $cutfile_syn_done) {
	  print "cutfile_syn_done ${cutfile_syn_done} already exists\n";

	} else {

	  if (not -f $cutfile_syn) {
	    print "cutfile_syn $cutfile_syn does not exist -- try iprocess = 2\n";

	  } else {

	    # read cut file
	    open(IN,"${cutfile_syn}"); @lines = <IN>; close(IN); $nlines = @lines;

	    $sacfile = "sacsyn.mac";
	    `echo echo on > $sacfile`;
	    `echo readerr badfile fatal >> $sacfile`;

	    for ($j = 1; $j <= $nlines; $j++) {

	      $line = $lines[$j-1]; chomp($line);
	      ($synfile_base,$b,$e,$npt,$dt) = split(" ",$line);

              # KEY: indicate the base directory
              $synfile = "${dirsyn_pro_1}/${synfile_base}";
              if (not -f $synfile) {die("synfile $synfile does not exist");}

	      print "$j out of $nlines -- $synfile\n";
	      #print "-- $datfile -- $synfile -- $b -- $e -- $npt -- $dt -- \n";

	      # cut records and fill zeros
	      `echo r $synfile >> $sacfile`;
	      `echo cuterr fillz >> $sacfile`;
	      `echo "cut $b n $npt" >> $sacfile`;
	      `echo r $synfile >> $sacfile`;
	      `echo cut off >> $sacfile`;
	      `echo w over >> $sacfile`;
	    } 
	    `echo quit >> $sacfile`;

	    # KEY: execute SAC command
	    `sac $sacfile`;
	    `sleep 5s`;
	    `rm $sacfile`;
	    print "\n Done cutting pre-processed syn files\n";

	    # copy syn cut file into syn directory
	    `cp ${cutfile_syn} ${cutfile_syn_done}`;

	  }			# cutfile exist
	}			# cutfile_done exist
      }				# bandpass dir exist
    }				# isyn
 
  }				# iprocess = 3


  #----------------------------------------------------------------------
  # PROCESSING PART 4: bandpass

  if ($iprocess == 4) {

    if ($isyn == 1) {
      if (-e ${dirsyn_pro_2}) {
	print "--> dirsyn ${dirsyn_pro_2} already exists\n";

      } else {
	if (not -f ${cutfile_syn_done}) {
	  print "cutfile_syn_done ${cutfile_syn_done} does not exist\n";

	} else {
	  if (not -e ${dirsyn_pro_1}) {
	    print "${dirsyn_pro_1} does not exist\n";

	  } else {
	    print CSH "cd ${dirsyn_pro_1}\n";
	    #print CSH "\\rm -rf $pdirbpass\n";
	    print CSH "process_trinet_syn_new.pl -S -t $Trange -d $pdirbpass -x $Ttag *.${syn_suffix} \n";
	    print CSH "cd $pdirbpass\n";
	    print CSH "rotate.pl *E.${syn_suffix}.${Ttag}\n";
	  }
	}
      }
    }				# isyn

    #-----------

    if ($idata == 1) {
      if (-e ${dirdat_pro_2}) {
	print "--> dirdat ${dirdat_pro_2} already exists\n";

      } else {
	if (not -f ${cutfile_dat_done}) {
	  print "cutfile_dat_done ${cutfile_dat_done} does not exist\n";

	} else {
	  if (not -e ${dirdat_pro_1}) {
	    print "${dirdat_pro_1} does not exist\n";

	  } else {
	    $ofile1 = "${eid}_ofile";
	    $ofile2 = "${eid}_no_pz_files";
	    $odir = "${dirdat0}/CHECK_DIR";
	    print CSH "mkdir -p $odir\n";

	    print CSH "cd ${dirdat_pro_1}\n";
	    #print CSH "\\rm -rf $pdirbpass\n";
	    print CSH "process_cal_data.pl -i none -t $Trange -d $pdirbpass -x $Ttag *.${dat_suffix} > $ofile1\n";
	    print CSH "grep skip $ofile1 | awk '{print \$7}' > $ofile2\n";
	    print CSH "\\cp $ofile1 $ofile2 $odir\n";

	    print CSH "cd $pdirbpass\n";
	    print CSH "rotate.pl *E.${dat_suffix}.${Ttag}\n";
	  }
	}
      }
    }				# idata

  }				# iprocess==4

}  # END OF LOOP OVER EVENTS

if($iprocess==0) {close(SYN);}

#======================
close(CSH);
print "closing $cshfile\n";
if($iexecute==1) {system("csh -f $cshfile");}

print "\n ";
#=================================================================
