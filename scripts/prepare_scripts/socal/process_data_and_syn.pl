#!/usr/bin/perl -w

#==========================================================
#
#  Carl Tape
#  19-June-2007
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
#  EXAMPLES:
#    ~/UTILS/process_data_and_syn.pl 0 1 d d 20 6/40 PROCESSED   # synthetics
#    ~/UTILS/process_data_and_syn.pl 1 0 d d 20 6/40 PROCESSED    # data
#    ~/UTILS/process_data_and_syn.pl 1 1 d d 20 6/40 PROCESSED    # both
#
#    ~/UTILS/process_data_and_syn.pl 0 1 d d 20 0.2/100 PROCESSED   # synthetics
#    ~/UTILS/process_data_and_syn.pl 1 0 d d 20 0.2/100 PROCESSED    # data
#    ~/UTILS/process_data_and_syn.pl 1 1 d d 20 0.2/100 PROCESSED    # both
#
#==========================================================

if (@ARGV < 7) {die("Usage: process_data_and_syn.pl idata isyn syn_ext dat_ext sps Tmin/Tmax \n")}
($idata,$isyn,$syn_ext,$dat_ext,$sps,$Trange,$pdir) = @ARGV;

$smodel = "m03";   # KEY: model iteration index
$iexecute = 0;
$ilist = 1;

# THESE MUST BE DONE IN SEQUENTIAL ORDER
$iprocess0 = 0;
$iprocess1 = 1;    # only done ONCE, no matter how many band-pass filters you use
$iprocess2 = 0;    # only done ONCE, no matter how many band-pass filters you use
$iprocess3 = 0;

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
$dir_source = "/net/sierra/raid1/carltape/results/SOURCES/socal_6";
$dirCMT    = "${dir_source}/v6_files";
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
$cshfile = "process_data_and_syn.csh";
print "\nWriting to $cshfile ...\n";
open(CSH,">$cshfile");

if($iprocess0==1) {
  $sfile = "nprocess_syn";
  open(SYN,">$sfile");
}

$imin = 1; $imax = $ncmt;  # default
#$imin = 1; $imax = $imin;
#$imin = 1; $imax = 160;

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

  #----------------------------------------------------------------------
  # PROCESSING PART 0: check the number of processed synthetic files for each event

  if ($iprocess0 == 1) {
     $dirsyn = "${dirsyn0}/${eid}";
     $dirsyn_pro = "$dirsyn/$pdir";
     if(-e $dirsyn_pro) {
       ($nfile,undef,undef) = split(" ",`ls -1 $dirsyn/$pdir/* | wc`);
       print SYN "$eid $nfile\n";
     }
  }

  #----------------------------------------------------------------------
  # PROCESSING PART 1: assigning SAC headers and interpolating

  if ($iprocess1 == 1) {

    # synthetics -- NOTE: convolve with half-duration (prior to interpolating)
    if ($isyn == 1) {
      $dirsyn = "${dirsyn0}/${eid}";
      if (-e $dirsyn) {
	if (not -e "$dirsyn/$pdir") {
	  print CSH "cd $dirsyn\n";
          #print CSH "mv $pdir ${pdir}_OLD\n";
	  #print CSH "\\rm -rf $pdir\n";
	  print CSH "process_trinet_syn_new.pl -S -m $cmtfile -h -a $stafile -s $sps -p -d $pdir -x ${syn_ext} *.${syn_suffix0} \n";
	} else {
	  print "$pdir already exists\n";
	}
      } else {
	print "$dirsyn does not exist\n";
      }
    }	  # isyn

    # data
    if ($idata == 1) {
      $dirdat = "${dirdat0}/${eid}";
      if (-e $dirdat) {
	if (not -e "$dirdat/$pdir") {
	print CSH "cd $dirdat\n";
        #print CSH "mv $pdir ${pdir}_OLD\n";
	#print CSH "\\rm -rf $pdir; mkdir $pdir\n";
	print CSH "process_cal_data.pl -m $cmtfile -p -s $sps -d $pdir -x ${dat_ext} *.${dat_suffix0}\n";
	} else {
	  print "$pdir already exists\n";
	}
      } else {
	print "$dirdat does not exist\n";
      }
    }	  # idata

    #  # process synthetics
    #  if ($isyn == 1) {
    #    $dirsyn = "${dirsyn0}/${eid}";
    #    #if (not -e $dirsyn) {die("check if $dirsyn exist or not\n")}
    #    if (-e $dirsyn) {
    #      if (not -e "$dirsyn/$pdir") {
    #        print CSH "cd $dirsyn\n";
    #	print CSH "\\rm -rf $pdir\n";
    #        #print CSH "~/UTILS/interp_records.pl -S -t 0.011 *.semd.sac \n";
    #	#print CSH "process_trinet_syn_new.pl -S -m $cmtfile -a $stafile -p -t $Trange -s 20 -d $pdir -x ${syn_ext} *.semd.sac \n";
    #        print CSH "process_trinet_syn_new.pl -S -m $cmtfile -h -a $stafile -p -d $pdir -x ${syn_ext} *.semd.sac \n";
    #	print CSH "cd $pdir\n";
    #	print CSH "rotate.pl *E.semd.sac.${syn_ext} \n";

    #	#print CSH "process_trinet_syn_new.pl -m $cmtfile -a $stafile *.semd \n";
    #	#print CSH "\\rm *sac.d *BHR* *BHT* \n";
    #	#print CSH "process_trinet_syn_new.pl -S -s 20 *.sac \n";
    #      }
    #    } else {
    #      print "\n $dirsyn does not exist";
    #    }
    #  }  # isyn

    #  # process data and make a list of files for which we are missing the PZ
    #  # At the end, from CHECK_DIR : cat *pz* > no_PoleZero_files
    #  if ($idata == 1) {
    #    $dirdat = "${dirdat0}/${eid}";
    #    if (-e $dirdat) {
    #      if (not -e "$dirdat/$pdir") {

    #	$ofile1 = "${eid}_ofile";
    #	$ofile2 = "${eid}_no_pz_files";
    #	$odir = "${dir_dat}/CHECK_DIR";
    #	print CSH "mkdir -p $odir\n";
    #	print CSH "cd $dirdat\n";
    #	print CSH "\\rm -rf $pdir; mkdir $pdir\n";

    #	# note -I to convert to displacement but NOT subsequently bandpass
    #	#print CSH "process_cal_data.pl -m $cmtfile -i none -p -t $Trange -s 20 -d $pdir -x ${dat_ext} *.sac > $ofile1 \n";
    #	print CSH "process_cal_data.pl -m $cmtfile -I none -p -t $Trange -d $pdir -x ${dat_ext} *.sac > $ofile1 \n";

    #	print CSH "grep skip $ofile1 | awk '{print \$7}' > $ofile2 \n";
    #	print CSH "\\cp $ofile1 $ofile2 $odir\n";
    #	print CSH "cd $pdir\n";
    #	print CSH "rotate.pl *E.sac.${dat_ext} \n";
    #      }
    #    } else {
    #      print "\n $dirdat does not exist";
    #    }
    #  }  # idata

  }

  #----------------------------------------------------------------------
  # PROCESSING PART 2: cutting records and padding zeros

  if ($iprocess2 == 1 || $iprocess3 == 1) {

    # both the processed synthetics and processed data directories must exist
    # base directories containing pre-processed data and synthetics
    $dirdat = "${dirdat0}/${eid}/$pdir";
    $dirsyn = "${dirsyn0}/${eid}/$pdir";
    $dirdat_pro = "$dirdat/$pdirbpass";
    $dirsyn_pro = "$dirsyn/$pdirbpass";

    if ( (not -e $dirdat) || (not -e $dirsyn) ) {
      print "--> dirdat $dirdat and dirsyn $dirsyn do not both exist\n";

    } else {
      if ( (-e $dirdat_pro && $idata==1) || (-e $dirsyn_pro && $isyn==1) ) {
	if ($idata == 1) {
	  print "$dirdat_pro already exists\n";
	}
	if ($isyn == 1) {
	  print "$dirsyn_pro already exists\n";
	}

      } else {

	if ($iprocess2 == 1) {
     
	  # base directories containing pre-processed data and synthetics
	  $dirdat = "${dirdat0}/${eid}/$pdir";
	  $dirsyn = "${dirsyn0}/${eid}/$pdir";

	  # grab all DATA files
	  @files = glob("${dirdat}/*");
	  $nfile = @files;
	  print "\n $nfile data files to line up with synthetics\n";

	  #------------------------

	  `echo echo on > sac.mac`;
	  `echo readerr badfile fatal >> sac.mac`;

	  foreach $file (@files) { 
	    # read the sac headers
	    (undef,$net,$sta,$chan) = split(" ",`saclst knetwk kstnm kcmpnm f $file`);
	    $comp = `echo $chan | awk '{print substr(\$1,3,1)}'`;
	    chomp($comp);
	    #print "\n $net $sta $chan $comp\n";

	    # synthetics are always BH_ component
	    $synt = "${dirsyn}/${sta}.${net}.BH${comp}.${syn_suffix}";
	    #print "\n $file $synt ";

	    # if the synthetic file exists, then go on
	    if (-f $synt) { 
	      print "\n $file $synt"; # only list files that are pairs

	      # get info on data and synthetics
	      `echo r $file >> sac.mac`;
	      `echo r $synt >> sac.mac`;
	      (undef,$bd,$ed,$deltad,$nptd) = split(" ",`saclst b e delta npts f $file`);
	      (undef,$bs,$es,$deltas,$npts) = split(" ",`saclst b e delta npts f $synt`);
	      $tlend = $ed - $bd;
	      $tlens = $es - $bs;
    
	      # dt should be the same for both records ALREADY
	      if (log($deltad/$deltas) > 0.01) {
		print "$file $synt\n";
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

	      $b = $b0;
	      $tlen0 = $e0 - $b;
	      $tlen = $tfac * $tlen0; # extend record length
	      $e = $b0 + $tlen;

	      $npt = int( ($e-$b)/$dt );

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

	      # cut records and fill zeros
	      `echo r $file $synt >> sac.mac`;
	      `echo cuterr fillz >> sac.mac`;
	      `echo "cut $b n $npt" >> sac.mac`;
	      `echo r $file $synt >> sac.mac`; # cut both
	      `echo cut off >> sac.mac`;
	      `echo w over >> sac.mac`;
	    }

	  } 
	  `echo quit >> sac.mac`;
	  `sac sac.mac`;	# KEY: EXECUTE the SAC commands
	  `rm sac.mac`;

	  print "\n Done with pre-processing, part 2\n";

	}

	#----------------------------------------------------------------------
	# PROCESSING PART 3: band-pass filter and rotate

	if ($iprocess3 == 1) {

	  if ($isyn == 1) {
	    $dirsyn = "${dirsyn0}/${eid}/$pdir";
	    if (-e $dirsyn) {
	      if (not -e "$dirsyn/$pdirbpass") {
		print CSH "cd $dirsyn\n";
		#print CSH "\\rm -rf $pdirbpass\n";
		print CSH "process_trinet_syn_new.pl -S -t $Trange -d $pdirbpass -x $Ttag *.${syn_suffix} \n";
		print CSH "cd $pdirbpass\n";
		print CSH "rotate.pl *E.${syn_suffix}.${Ttag}\n";

	      } else {
		print "$pdirbpass already exists\n";
	      }
	    } else {
	      print "$dirsyn does not exist\n";
	    }
	  }			# isyn


	  # data
	  if ($idata == 1) {
	    $dirdat = "${dirdat0}/${eid}/$pdir";
	    if (-e $dirdat) {
	      if (not -e "$dirdat/$pdirbpass") {

		$ofile1 = "${eid}_ofile";
		$ofile2 = "${eid}_no_pz_files";
		$odir = "${dirdat0}/CHECK_DIR";
		print CSH "mkdir -p $odir\n";

		print CSH "cd $dirdat\n";
		#print CSH "\\rm -rf $pdirbpass\n";
		print CSH "process_cal_data.pl -i none -t $Trange -d $pdirbpass -x $Ttag *.${dat_suffix} > $ofile1\n";
		print CSH "grep skip $ofile1 | awk '{print \$7}' > $ofile2\n";
		print CSH "\\cp $ofile1 $ofile2 $odir\n";

		print CSH "cd $pdirbpass\n";
		print CSH "rotate.pl *E.${dat_suffix}.${Ttag}\n";

	      } else {
		print "$pdirbpass already exists\n";
	      }
	    } else {
	      print "$dirdat does not exist\n";
	    }
	  }   # idata
	}     # iprocess3=1
      }       # if data (or syn) have already been bandpass filtered
    }         # dirdat and dirsyn exist
  }           # iprocess2=1 or iprocess3=1

}

if($iprocess0==1) {close(SYN);}

#======================
close(CSH);
if($iexecute==1) {system("csh -f $cshfile");}

print "\n ";
#=================================================================
