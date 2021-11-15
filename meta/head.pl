#!/usr/bin/perl

while (<>) {
	@data=split();
	die $_ unless (@data==4 || @data==5);
	($path, $size, $tm, $head, $tag)=@data;
	die unless $path=~/^\/projects\/ps-renlab\/fastq\/(\S+)\/(\S+)$/;
	($short_path, $file)=($1, $2);
	if ($short_path=~/(\d\d\d\d)_(\d\d)_(\d\d)/) {
		($y, $m, $d)=($1,$2,$3);
	} elsif ($short_path=~/(\d\d\d\d)_(\d\d)(\d\d)_/) {
		($y, $m, $d)=($1,$2,$3);
	} elsif ($short_path=~/_(\d\d)(\d\d)(20\d\d)_/) {
		($y, $m, $d)=($3,$1,$2);
	} else {
		die $short_path;
	}
	die unless $d<=31 && $m<=12; $mdy="$m/$d/$y";
    ## $short_path, $file, $mdy, $size

	if ($tag) {
		# https://kscbioinformatics.wordpress.com/2017/02/03/raw-illumina-sequence-data-files-for-dummies-part-1/
		if ($head=~/^(\S+):(\d+):(\S+):(\d):(\d+):(\d+):(\d+)$/) {
			($machine, $rid, $fcid, $ln, $tile, $x, $y)=($1,$2,$3,$4,$5,$6,$7);
		} elsif ($head=~/^(\S+):(\d+):(\S+):(\d):(\d+):(\d+):(\d+):(\S+)$/) {
			# @VH00454:6:AAAKTJ3M5:1:1102:47676:10977:TGAGAGGCTA 
			($machine, $rid, $fcid, $ln, $tile, $x, $y, $seq0)=($1,$2,$3,$4,$5,$6,$7,$8);
		} else {
			die $_;
		}
		die $_ unless $tag=~/^(\d):([YN]):(\d):(\S*)$/;
		($pair, $filtered, $ctl, $idx)=($1,$2,$3,$4);
        ## $machine, $rid, $fcid, $ln, $tile, $x, $y, [$seq0], $pair, $filtered, $ctl, $idx
	} else {
		# https://en.wikipedia.org/wiki/FASTQ_format
		if ($head=~/^(\S+)_(\d+):(\d):(\d+):(\d+):(\d+)#(\S+)\/(\d)$/) {
			($machine, $run, $ln, $tile, $x, $y, $idx, $pair)=($1,$2,$3,$4,$5,$6,$7,$8);
		} elsif ($head=~/^(\S+)_(\d+):(\d):(\d+):(\d+):(\d+)$/) {
            ($machine, $run, $ln, $tile, $x, $y)=($1,$2,$3,$4,$5,$6);
		} else {
			die $_;
		}
        $fcid="${machine}_$run";
        ## $machine,   $run         $ln, $tile, $x, $y,         [$pair],                [$idx]
	}
    ## $machine, $fcid_or_run
    $key="$short_path.$fcid";
    $run_info="\"path\": \"$short_path\", \"fcid\": \"$fcid\", \"mdy\": \"$mdy\", \"machine\": \"$machine\"";
    if (exists $INFO{$key}) {
        # make sure same: $path, $fcid, $date, $machine are the same
        die $_ unless $run_info eq $INFO{$key};
    } else {
        # add $short_path, $fcid, $date & $machine
        $INFO{$key}=$run_info;
    }
    # push: $file, $size
    $files="{ \"file\": \"$file\", \"size\": \"$size\" }";
    push(@{$LST{$key}}, $files);
}

sub byDate {
    die $INFO{$a} unless $INFO{$a}=~/"mdy": "(\d+)\/(\d+)\/(\d+)"/; ($ma,$da,$ya)=($1,$2,$3);
    die $INFO{$b} unless $INFO{$b}=~/"mdy": "(\d+)\/(\d+)\/(\d+)"/; ($mb,$db,$yb)=($1,$2,$3);
    return $yb<=>$ya if $ya!=$yb;
    return $mb<=>$ma if $ma!=$mb;
    return $db<=>$da if $da!=$db;
    return $a<=>$b;
}

print "[\n"; $N=0;
foreach $k (sort byDate keys %INFO) {
	print ",\n" if $N++;
    print("{ $INFO{$k}, \"hasSampleSheet\": \"false\", \"hasDoc\": \"false\",\"files\": [\n".join(",\t\n", @{$LST{$k}})."]}");
}
print "\n]";

__END__
/projects/ps-renlab/fastq/2021/2021_03_09_NS/fastq/CZ786_S2_L001_R2_001.fastq.gz 301252040 1615508935.8529025490 @VH00454:1:AAACYFJHV:1:1101:50157:1000 2:N:0:CGATGT
/projects/ps-renlab/fastq/2021/2021_03_09_NS/fastq/CZ790_S6_L002_R2_001.fastq.gz 90546218 1615508999.2204648920 @VH00454:1:AAACYFJHV:2:1101:31751:1000 2:N:0:CAGATC
/projects/ps-renlab/fastq/2021/2021_03_09_NS/fastq/YX004_S26_L001_R1_001.fastq.gz 1246373248 1615510332.4832962510 @VH00454:1:AAACYFJHV:1:1101:32774:1000 1:N:0:CTTGTA
/projects/ps-renlab/fastq/2021/2021_03_09_NS/fastq/CZ795_S13_L001_R2_001.fastq.gz 419840225 1615509329.4033888980 @VH00454:1:AAACYFJHV:1:1101:43946:1000 2:N:0:CATGGC
/projects/ps-renlab/fastq/2021/2021_03_09_NS/fastq/CZ775_S8_L002_R1_001.fastq.gz 1313636346 1615508817.3138495280 @VH00454:1:AAACYFJHV:2:1101:32206:1000 1:N:0:CAACTA
/projects/ps-renlab/fastq/2021/2021_03_09_NS/fastq/CZ796_S14_L002_R1_001.fastq.gz 402711315 1615509358.1306454150 @VH00454:1:AAACYFJHV:2:1101:33607:1000 1:N:0:CATTTT
/projects/ps-renlab/fastq/2021/2021_03_09_NS/fastq/CZ790_S6_L002_R1_001.fastq.gz 71941829 1615508997.9764538560 @VH00454:1:AAACYFJHV:2:1101:31751:1000 1:N:0:CAGATC
/projects/ps-renlab/fastq/2021/2021_03_09_NS/fastq/YX004_S26_L001_R2_001.fastq.gz 1292965724 1615510352.3614718190 @VH00454:1:AAACYFJHV:1:1101:32774:1000 2:N:0:CTTGTA
/projects/ps-renlab/fastq/2021/2021_03_09_NS/fastq/CZ786_S2_L001_R1_001.fastq.gz 296580423 1615508931.7028657060 @VH00454:1:AAACYFJHV:1:1101:50157:1000 1:N:0:CGATGT
/projects/ps-renlab/fastq/2021/2021_03_09_NS/fastq/CZ796_S14_L002_R2_001.fastq.gz 384399817 1615509363.0916897050 @VH00454:1:AAACYFJHV:2:1101:33607:1000 2:N:0:CATTTT
/projects/ps-renlab/fastq/2009/2009_03_20/fastq_files/lane7.fastq.gz 243543391 1519255066.3580226560 @SOLEXA2_0020:7:1:0:116#0/1
/projects/ps-renlab/fastq/2009/2009_03_20/fastq_files/lane6.fastq.gz 286865366 1519255066.3610226780 @SOLEXA2_0020:6:1:0:95#0/1
/projects/ps-renlab/fastq/2009/2009_03_20/fastq_files/lane1.fastq.gz 421338942 1519255066.3640227000 @SOLEXA2_0020:1:1:0:17#0/1
/projects/ps-renlab/fastq/2009/2009_03_20/fastq_files/lane2.fastq.gz 426483670 1519255066.3670227220 @SOLEXA2_0020:2:1:0:68#0/1
/projects/ps-renlab/fastq/2009/2009_03_20/fastq_files/lane5.fastq.gz 354212001 1519255066.3700227440 @SOLEXA2_0020:5:1:0:59#0/1
